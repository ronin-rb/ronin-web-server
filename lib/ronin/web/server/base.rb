# frozen_string_literal: true
#
# ronin-web-server - A custom Ruby web server based on Sinatra.
#
# Copyright (c) 2006-2026 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require_relative 'request'
require_relative 'response'
require_relative 'routing'
require_relative 'helpers'
require_relative 'conditions'

require 'rack'
require 'sinatra/base'
require 'rack/user_agent'

module Ronin
  module Web
    module Server
      #
      # The base-class for all Ronin Web Servers. Extends
      # [Sinatra::Base](http://rubydoc.info/gems/sinatra/Sinatra/Base)
      # with additional {Routing routing methods}, {Helpers helper methods} and
      # Sinatra {Conditions conditions}.
      #
      # ## Routing Methods
      #
      # * {Routing::ClassMethods#any any}: registers a route that responds to
      #   `GET`, `POST`, `PUT`, `PATCH`, `DELETE` and `OPTIONS` requests.
      # * {Routing::ClassMethods#default default}: registers the default route.
      # * {Routing::ClassMethods#basic_auth basic_auth}: enables Basic-Auth
      #   authentication for the whole app.
      # * {Routing::ClassMethods#redirect redirect}: adds a route that simply
      #   redirects to another URL.
      # * {Routing::ClassMethods#file file}: mounts a file at the given path.
      #   a given file.
      # * {Routing::ClassMethods#directory directory}: mounts a directory at
      #   the given path.
      # * {Routing::ClassMethods#public_dir public_dir}: mounts a directory
      #   at the root.
      # * {Routing::ClassMethods#vhost vhost}: mounts a Rack app for the given
      #   vhost.
      # * {Routing::ClassMethods#mount mount}: mounts a Rack app at the given
      #   path.
      #
      # ## Helper Methods
      #
      # * {Helpers#h h}: escapes HTML entities.
      # * {Helpers#file file}: sends a file.
      # * {Helpers#mime_type_for mime_type_for}: returns the MIME type for the
      #   file.
      # * {Helpers#content_type_for content_type_for}: sets the `Content-Type`
      #   for the file.
      #
      # ## Routing Conditions
      #
      # * {Conditions::ClassMethods#client_ip client_ip}: filters requests
      #   based on their client IP address.
      # * {Conditions::ClassMethods#asn asn}: filters requests by the client
      #   IP's ASN number.
      # * {Conditions::ClassMethods#country_code country_code}: filters requests
      #   by the client IP's ASN country code.
      # * {Conditions::ClassMethods#asn_name asn_name}: filters requests by the
      #   client IP's ASN company/ISP name.
      # * {Conditions::ClassMethods#host host}: filters requests based on the
      #   `Host` header.
      # * {Conditions::ClassMethods#referer referer}: filters requests based on
      #   the `Referer` header.
      # * {Conditions::ClassMethods#user_agent user_agent}: filters requests
      #   based on the `User-Agent` header.
      # * {Conditions::ClassMethods#browser browser}: filters requests based on
      #   the browser name within the `User-Agent` header.
      # * {Conditions::ClassMethods#browser_version browser_version}: filters
      #   requests based on the browser version within the `User-Agent` header.
      # * {Conditions::ClassMethods#device_type device_type}: filters requests
      #   based on the device type within the `User-Agent` header.
      # * {Conditions::ClassMethods#os os}: filters requests based on the OS
      #   within the `User-Agent` header.
      # * {Conditions::ClassMethods#os_version os_version}: filters requests
      #   based on the OS version within the `User-Agent` header.
      #
      # ## Examples
      #
      #   require 'ronin/web/server'
      #
      #   class App < Ronin::Web::Server::Base
      #
      #     # mount a file
      #     file '/sitemap.xml', './files/sitemap.xml'
      #
      #     # mount a directory
      #     directory '/downloads/', '/tmp/downloads/'
      #
      #     get '/' do
      #       # renders views/index.erb
      #       erb :index
      #     end
      #
      #     get '/test' do
      #       "raw text here"
      #     end
      #
      #   end
      #
      #   App.run!
      #
      class Base < Sinatra::Base

        include Server::Routing
        include Server::Helpers
        include Server::Conditions

        # Default interface to run the Web Server on
        DEFAULT_HOST = '0.0.0.0'

        # Default port to run the Web Server on
        DEFAULT_PORT = 8000

        use Rack::UserAgent

        set :bind, DEFAULT_HOST
        set :port, DEFAULT_PORT

        set :host_authorization, -> { {} }

        before do
          @request  = Request.new(@env)
          @response = Response.new
        end

        not_found { [404, {'Content-Type' => 'text/html'}, ['']] }

        #
        # Run the web server.
        #
        # @param [Hash] options Additional options.
        #
        # @option options [String] :host
        #   The host the server will listen on.
        #
        # @option options [Integer] :port
        #   The port the server will bind to.
        #
        # @option options [String] :server
        #   The Web Server to run on.
        #
        # @option options [Boolean] :background (false)
        #   Specifies wether the server will run in the background or run
        #   in the foreground.
        #
        # @raise [Errno::EADDRINUSE]
        #   The port is already in use.
        #
        # @api public
        #
        def self.run!(options={},&block)
          if options[:background]
            Thread.new(options) { |options| super(options) }
          else
            super(options,&block)
          end
        end

      end
    end
  end
end
