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

require 'ronin/web/server/base'
require 'ronin/web/server/app'

module Ronin
  module Web
    #
    # Returns the Ronin Web Server.
    #
    # @param [Hash] options
    #   Additional options.
    #
    # @yield [server]
    #   If a block is given, it will be passed the current web server.
    #
    # @yieldparam [Server::App]
    #   The current web server class.
    #
    # @return [Server::App]
    #   The current web server class.
    #
    # @example
    #   Web.server do
    #     get '/hello' do
    #       'world'
    #     end
    #   end
    #
    # @see Server::Base.run!
    #
    # @api public
    #
    def self.server(options={},&block)
      unless class_variable_defined?('@@ronin_web_server')
        @@ronin_web_server = Server::App
        @@ronin_web_server.run!(options.merge(background: true))
      end

      @@ronin_web_server.class_eval(&block) if block
      return @@ronin_web_server
    end
  end
end
