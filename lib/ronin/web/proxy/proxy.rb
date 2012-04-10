#
# Ronin Web - A Ruby library for Ronin that provides support for web
# scraping and spidering functionality.
#
# Copyright (c) 2006-2012 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of Ronin Web.
#
# Ronin is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ronin is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ronin.  If not, see <http://www.gnu.org/licenses/>.
#

require 'ronin/web/proxy/request'
require 'ronin/web/proxy/response'

require 'ronin/network/http'
require 'set'

module Ronin
  module Web
    #
    # A Rack middleware for proxying requests.
    #
    #     server.route '/forum/', Proxy.new do |proxy|
    #       proxy.on_request do |request|
    #         puts request.url
    #       end
    #
    #       proxy.on_response do |response|
    #         response.headers.each do |name,value|
    #           puts "#{name}: #{value}"
    #         end
    #
    #         puts response.body
    #       end
    #     end
    #
    # @since 1.0.0
    #
    # @api semipublic
    #
    class Proxy

      include Ronin::Network::HTTP

      # Blacklisted HTTP response Headers.
      HEADERS_BLACKLIST = Set[
        'Transfer-Encoding'
      ]

      #
      # Creates a new {Proxy} middleware.
      #
      # @yield [proxy]
      #   If a block is given, it will be passed the new proxy middleware.
      #
      # @yieldparam [Proxy] proxy
      #   The new proxy middleware object.
      #
      def initialize
        yield self if block_given?
      end

      #
      # Uses the given block to intercept incoming requests.
      #
      # @yield [request]
      #   The given block will receive every incoming request, before it
      #   is proxied.
      #
      # @yieldparam [ProxyRequest] request
      #   A proxied request.
      #
      # @return [Proxy]
      #   The proxy middleware.
      #
      # @api public
      #
      def on_request(&block)
        @on_request_block = block
        return self
      end

      #
      # Uses the given block to intercept proxied responses.
      #
      # @yield [response]
      #   The given block will receive every proxied response.
      #
      # @yieldparam [Response] response
      #   A proxied response.
      #
      # @return [Proxy]
      #   The proxy middleware.
      #
      # @api public
      #
      def on_response(&block)
        @on_response_block = block
        return self
      end

      #
      # @see #call!
      #
      # @api semipublic
      #
      def call(env)
        dup.call!(env)
      end

      #
      # Receives incoming requests, proxies them, allowing manipulation
      # of the requests and their responses.
      #
      # @param [Hash, Rack::Request] env
      #   The request.
      #
      # @return [Array, Response]
      #   The response.
      #
      # @api private
      #
      def call!(env)
        request = Request.new(env)

        @every_request_block.call(request) if @every_request_block

        print_debug "Proxying #{request.url} for #{request.address}"
        request.headers.each do |name,value|
          print_debug "  #{name}: #{value}"
        end

        response = proxy(request)

        @every_response_block.call(response) if @every_response_block

        print_debug "Returning proxied response for #{request.address}"
        response.headers.each do |name,value|
          print_debug "  #{name}: #{value}"
        end

        return response
      end

      protected

      #
      # Proxies a request.
      #
      # @param [ProxyRequest] request
      #   The request to send.
      #
      # @return [Response]
      #   The response from the request.
      #
      # @api private
      #
      def proxy(request)
        options = {
          :ssl          => (request.scheme == 'https'),
          :host         => request.host,
          :port         => request.port,
          :method       => request.request_method,
          :path         => request.path_info,
          :query        => request.query_string,
          :content_type => request.content_type,
          :headers      => request.headers
        }

        if request.form_data?
          options[:form_data] = request.POST
        end

        http_response = http_request(options)
        http_headers = {}

        http_response.each_capitalized do |name,value|
          unless HEADERS_BLACKLIST.include?(name)
            http_headers[name] = value
          end
        end

        return Response.new(
          (http_response.body || ''),
          http_response.code,
          http_headers
        )
      end

    end
  end
end
