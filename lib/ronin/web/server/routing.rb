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

require 'rack/file'
require 'rack/directory'

module Ronin
  module Web
    module Server
      #
      # Adds additional routing class methods to {Base}.
      #
      # @api semipublic
      #
      module Routing
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          #
          # Route any type of request for a given URL pattern.
          #
          # @param [String] path
          #   The URL pattern to handle requests for.
          #
          # @param [Hash{Symbol => Object}] conditions
          #   Additional routing conditions.
          #
          # @yield []
          #   The block that will handle the request.
          #
          # @example
          #   any '/submit' do
          #     puts request.inspect
          #   end
          #
          # @api public
          #
          def any(path,conditions={},&block)
            get(path,conditions,&block)
            post(path,conditions,&block)
            put(path,conditions,&block)
            patch(path,conditions,&block)
            delete(path,conditions,&block)
            options(path,conditions,&block)
          end

          #
          # Sets the default route.
          #
          # @yield []
          #   The block that will handle all other requests.
          #
          # @example
          #   default do
          #     status 200
          #     content_type :html
          #     
          #     %{
          #     <html>
          #       <body>
          #         <center><h1>YOU LOSE THE GAME</h1></center>
          #       </body>
          #     </html>
          #     }
          #   end
          #
          # @api public
          #
          def default(&block)
            not_found(&block)
            return self
          end

          #
          # Enables Basic-Auth authentication for the entire app.
          #
          # @param [String] auth_user
          #   The desired username.
          #
          # @param [String] auth_password
          #   The desired password
          #
          # @param [String] realm
          #   The "realm" message to display in the Basic-Auth dialog.
          #
          # @example
          #   basic_auth 'admin', 's3cr3t'
          #
          def basic_auth(auth_user,auth_password, realm: 'Restricted')
            use Rack::Auth::Basic, realm do |user,password|
              user == auth_user && passwrd == auth_password
            end
          end

          #
          # Sets up a 302 Redirect at the given path.
          #
          # @param [String] path
          #   The path  the web server will respond to.
          #
          # @param [String] url
          #   The URL to redirect to.
          #
          # @api public
          #
          def redirect(path,url)
            get(path) { redirect(url) }
          end

          #
          # Hosts the contents of a file.
          #
          # @param [String, Regexp] remote_path
          #   The path the web server will host the file at.
          #
          # @param [String] local_path
          #   The path to the local file.
          #
          # @param [Hash{Symbol => Object}] conditions
          #   Additional routing conditions.
          #
          # @example
          #   file '/robots.txt', '/path/to/my_robots.txt'
          #
          # @api public
          #
          def file(remote_path,local_path,conditions={})
            get(remote_path,conditions) { send_file(local_path) }
          end

          #
          # Hosts the contents of files.
          #
          # @param [Hash{String,Regexp => String}] paths
          #   The mapping of remote paths to local paths.
          #
          # @param [Hash{Symbol => Object}] conditions
          #   Additional routing conditions.
          #
          # @example
          #   files '/foo.txt' => 'foo.txt'
          #
          # @example
          #   files(
          #     '/foo.txt' => 'foo.txt'
          #     /\.exe$/   => 'trojan.exe'
          #   )
          #
          # @see #file
          #
          # @api public
          #
          def files(paths,conditions={})
            paths.each do |remote_path,local_path|
              file(remote_path,local_path,conditions)
            end
          end

          #
          # Hosts the contents of the directory.
          #
          # @param [String] remote_path
          #   The path the web server will host the directory at.
          #
          # @param [String] local_path
          #   The path to the local directory.
          #
          # @param [Hash{Symbol => Object}] conditions
          #   Additional routing conditions.
          #
          # @example
          #   directory '/download/', '/tmp/files/'
          #
          # @api public
          #
          def directory(remote_path,local_path,conditions={})
            dir = Rack::File.new(local_path)

            get("#{remote_path}/*",conditions) do |sub_path|
              response = dir.call(env.merge('PATH_INFO' => "/#{sub_path}"))

              if response[0] == 200 then response
              else                       pass
              end
            end
          end

          #
          # Hosts the contents of directories.
          #
          # @param [Hash{String => String}] paths
          #   The mapping of remote paths to local directories.
          #
          # @param [Hash{Symbol => Object}] conditions
          #   Additional routing conditions.
          #
          # @example
          #   directories '/downloads' => '/tmp/ronin_downloads'
          #
          # @see #directory
          #
          # @api public
          #
          def directories(paths,conditions={},&block)
            paths.each do |remote_path,local_path|
              directory(remote_path,local_path,conditions)
            end
          end

          #
          # Hosts the static contents within a given directory.
          #
          # @param [String] path
          #   The path to a directory to serve static content from.
          #
          # @param [Hash{Symbol => Object}] conditions
          #   Additional routing conditions.
          #
          # @example
          #   public_dir 'path/to/another/public'
          #
          # @api public
          #
          def public_dir(path,conditions={})
            directory('',path,conditions)
          end

          #
          # Routes all requests for a given virtual host to another
          # Rack application.
          #
          # @param [Regexp, String] host
          #   The host name to match against.
          #
          # @param [#call] server
          #   The Rack application to route the requests to.
          #
          # @param [Hash] conditions
          #   Additional routing conditions.
          #
          # @api public
          #
          def host(host,server,conditions={})
            any('*',conditions.merge(host: host)) do
              server.call(env)
            end
          end

          #
          # Routes all requests within a given directory into another
          # Rack application.
          #
          # @param [String] dir
          #   The directory that requests for will be routed from.
          #
          # @param [#call] server
          #   The Rack application to route requests to.
          #
          # @param [Hash{Symbol => Object}] conditions
          #   Additional routing conditions.
          #
          # @example
          #   map '/subapp/', SubApp
          #
          # @api public
          #
          def map(dir,server,conditions={})
            any("#{dir}/?*",conditions) do |sub_path|
              server.call(env.merge('PATH_INFO' => "/#{sub_path}"))
            end
          end
        end
      end
    end
  end
end
