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

require 'sinatra/base'
require 'rack/utils'

module Ronin
  module Web
    module Server
      #
      # Provides Sinatra routing and helper methods.
      #
      module Helpers
        include Rack::Utils
        include Sinatra::Helpers

        alias h escape_html
        alias file send_file

        #
        # Returns the MIME type for a path.
        #
        # @param [String] path
        #   The path to determine the MIME type for.
        #
        # @return [String]
        #   The MIME type for the path.
        #
        # @api public
        #
        def mime_type_for(path)
          mime_type(File.extname(path))
        end

        #
        # Sets the `Content-Type` for the file.
        #
        # @param [String] path
        #   The path to determine the `Content-Type` for.
        #
        # @api public
        #
        def content_type_for(path)
          content_type mime_type_for(path)
        end
      end
    end
  end
end
