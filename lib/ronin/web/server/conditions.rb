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

require 'ipaddr'

module Ronin
  module Web
    module Server
      #
      # Defines Sinatra routing conditions.
      #
      # @api semipublic
      #
      module Conditions
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          protected

          #
          # Condition to match the IP Address that sent the request.
          #
          # @param [IPAddr, String, Proc, #===] ip
          #   The IP address or range of addresses to match against.
          #
          def ip_address(ip)
            condition { ip === request.ip }
          end

          #
          # Condition for matching the `Host` header.
          #
          # @param [Regexp, String, Proc, #===] pattern
          #   The host to match against.
          #
          def host(pattern)
            condition { pattern === request.host }
          end

          #
          # Condition to match the `Referer` header of the request.
          #
          # @param [Regexp, String, Proc, #===] pattern
          #   Regular expression or exact `Referer` header to match against.
          #
          def referer(pattern)
            condition { pattern === request.referer }
          end

          alias referrer referer
        end
      end
    end
  end
end
