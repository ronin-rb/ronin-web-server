#
# ronin-web-server - A custom Ruby web server based on Sinatra.
#
# Copyright (c) 2006-2022 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of ronin-web-server.
#
# ronin-web-server is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ronin-web-server is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with ronin-web-server.  If not, see <https://www.gnu.org/licenses/>.
#

require 'ronin/web/server/reverse_proxy/request'
require 'ronin/web/server/reverse_proxy/response'
require 'ronin/support/network/http'

require 'rack'

module Ronin
  module Web
    module Server
      #
      # Reverse proxies Rack requests to other HTTP web servers.
      #
      # ## Examples
      #
      # ### Standalone Server
      #
      #     reverse_proxy = Ronin::Web::Server::ReverseProxy.new do |proxy|
      #       proxy.on_request do |request|
      #         # ...
      #       end
      #    
      #       proxy.on_response do |response|
      #         # ...
      #       end
      #     end
      #     reverse_proxy.run!(host: '0.0.0.0', port: 8080)
      #
      # ### App
      #
      #     class App < Ronin::Web::Server::Base
      #     
      #       mount '/signin', Ronin::Web::Server::ReverseProxy.new
      #     
      #     end
      #
      # @api public
      #
      class ReverseProxy

        #
        # Creates a new reverse proxy application.
        #
        # @yield [reverse_proxy]
        #   If a block is given, it will be passed the new proxy.
        #
        # @yieldparam [ReverseProxy] proxy
        #   The new proxy object.
        #
        def initialize
          @connections = {}

          yield self if block_given?
        end

        #
        # Registers a callback to run on each request.
        #
        # @yield [request]
        #   The given block will be passed each received request before it has
        #   been reverse proxied.
        #
        def on_request(&block)
          @on_request_callback = block
        end

        #
        # Registers a callback to run on each response.
        #
        # @yield [response]
        #   The given block will be passed each response before it has been
        #   returned.
        #
        # @yield [request, response]
        #   If the block accepts two arguments then both the request and the
        #   response objects will be yielded.
        #
        # @yieldparam [ReverseProxy::Response] response
        #   A response object.
        #
        # @yieldparam [ReverseProxy::Request] request
        #   A request object.
        #
        def on_response(&block)
          @on_response_callback = block
        end

        #
        # Reverse proxies every request using the `Host` header.
        #
        # @param [Hash{String => Object}] env
        #   The rack request env Hash.
        #
        # @return [ReverseProxy::Response]
        #   The rack response.
        #
        def call(env)
          request = Request.new(env)
          @on_request_callback.call(request) if @on_request_callback

          response = reverse_proxy(request)

          if @on_response_callback
            if @on_response_callback.arity == 1
              @on_response_callback.call(response)
            else
              @on_response_callback.call(request,response)
            end
          end

          return response
        end

        #
        # Creates a new connection or fetches an existing connection.
        #
        # @param [String] host
        #   The host to connect to.
        #
        # @param [Integer] port
        #   The port to connect to.
        #
        # @param [Boolean] ssl
        #   Indicates whether to use SSL.
        #
        # @return [Ronin::Support::Network::HTTP]
        #   The HTTP connection.
        #
        # @api private
        #
        def connection_for(host,port, ssl: nil)
          key = [host,port,ssl]

          @connections.fetch(key) do
            @connections[key] = Support::Network::HTTP.new(host,port, ssl: ssl)
          end
        end

        # Blacklisted HTTP response Headers.
        IGNORED_HEADERS = Set[
          'Transfer-Encoding'
        ]

        #
        # Reverse proxies the given request.
        #
        # @param [ReverseProxy::Request] request
        #   The incoming request to reverse proxy.
        #
        # @return [ReverseProxy::Response]
        #   The reverse proxied response.
        #
        def reverse_proxy(request)
          host    = request.host
          port    = request.port
          ssl     = request.scheme == 'https'
          method  = request.request_method.downcase.to_sym
          path    = request.path
          query   = request.query_string
          headers = request.headers
          body    = request.body.read

          http = connection_for(host,port, ssl: ssl)
          http_response = http.request(method,path, query:   query,
                                                    headers: headers,
                                                    body:    body)
          response_headers = {}

          http_response.each_capitalized do |name,value|
            unless IGNORED_HEADERS.include?(name)
              response_headers[name] = value
            end
          end

          response_body   = http_response.body || ''
          response_status = http_response.code.to_i

          return Response.new(response_body,response_status,response_headers)
        end

        #
        # @group Standalone Server Methods
        #

        # Default host the Proxy will bind to
        DEFAULT_HOST = '0.0.0.0'

        # Default port the Proxy will listen on
        DEFAULT_PORT = 8080

        # Default server the Proxy will run on
        DEFAULT_SERVER = 'webrick'

        #
        # Runs the reverse proxy as a standalone HTTP server.
        #
        # @param [String] host
        #   The host to bind to.
        #
        # @param [Integer] port
        #   The port to listen on.
        #
        # @param [String] server
        #   The Rack server to run the reverse proxy under.
        #
        # @param [Hash{Symbol => Object}] rack_options
        #   Additional options to pass to [Rack::Server.new](https://rubydoc.info/gems/rack/Rack/Server#initialize-instance_method).
        #
        def run!(host: DEFAULT_HOST, port: DEFAULT_PORT, server: DEFAULT_SERVER,
                 **rack_options)
          server = Rack::Server.new(
            app:    self,
            server: server,
            Host:   host,
            Port:   port,
            **rack_options
          )

          server.start do |handler|
            trap(:INT)  { quit!(server,handler) }
            trap(:TERM) { quit!(server,handler) }
          end

          return self
        end

        #
        # Stops the reverse proxy server.
        #
        # @param [Rack::Server] server
        #   The Rack Handler server.
        #
        # @param [#stop!, #stop] handler
        #   The Rack Handler.
        #
        # @api private
        #
        def quit!(server,handler)
          # Use thins' hard #stop! if available, otherwise just #stop
          handler.respond_to?(:stop!) ? handler.stop! : handler.stop
        end

      end
    end
  end
end
