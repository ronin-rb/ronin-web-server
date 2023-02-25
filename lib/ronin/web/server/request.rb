# frozen_string_literal: true
#
# ronin-web-server - A custom Ruby web server based on Sinatra.
#
# Copyright (c) 2006-2023 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require 'sinatra/base'

module Ronin
  module Web
    module Server
      #
      # Convenience class that represents requests.
      #
      # @see http://rubydoc.info/gems/rack/Rack/Request
      #
      class Request < Sinatra::Request

        alias client_ip ip

        #
        # Returns the remote IP address and port for the request.
        #
        # @return [String]
        #   The IP address and port number.
        #
        # @api semipublic
        #
        def ip_with_port
          if env.has_key?('REMOTE_PORT')
            "#{ip}:#{env['REMOTE_PORT']}"
          else
            ip
          end
        end

        #
        # The HTTP Headers for the request.
        #
        # @return [Hash{String => String}]
        #   The HTTP Headers of the request.
        #
        # @api public
        #
        def headers
          headers = {}

          env.each do |name,value|
            if name =~ /^HTTP_/
              header_words = name[5..].split('_')
              header_words.each(&:capitalize!)

              header_name = header_words.join('-')

              headers[header_name] = value
            end
          end

          return headers
        end

      end
    end
  end
end
