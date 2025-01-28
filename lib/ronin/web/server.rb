# frozen_string_literal: true
#
# ronin-web-server - A custom Ruby web server based on Sinatra.
#
# Copyright (c) 2006-2025 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require_relative 'server/base'
require_relative 'server/app'

module Ronin
  #
  # Namespace for [ronin-web].
  #
  # [ronin-web]: https://github.com/ronin-rb/ronin-web#readme
  #
  module Web
    #
    # Returns the Ronin Web Server.
    #
    # @param [Hash] options
    #   Additional options.
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
      unless @server
        @server = Server::App
        @server.run!(options.merge(background: true))
      end

      @server.class_eval(&block) if block
      return @server
    end
  end
end
