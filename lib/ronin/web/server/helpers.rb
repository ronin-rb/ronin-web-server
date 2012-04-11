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

require 'ronin/web/proxy'
require 'ronin/ui/output/helpers'
require 'ronin/templates/erb'
require 'ronin/extensions/meta'
require 'ronin/target'

require 'sinatra/base'
require 'rack/utils'
require 'rack/file'
require 'rack/directory'
require 'ipaddr'

module Ronin
  module Web
    module Server
      module Helpers

        include Rack::Utils
        include Sinatra::Helpers
        include Templates::Erb
        include UI::Output::Helpers

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
          # @since 0.2.0
          #
          # @api public
          #
          def any(path,conditions={},&block)
            get(path,conditions,&block)
            post(path,conditions,&block)
            put(path,conditions,&block)
            patch(path,conditions,&block)
            delete(path,conditions,&block)
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
          # @since 0.2.0
          #
          # @api public
          #
          def default(&block)
            class_def(:default_response,&block)
            return self
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
          # @since 0.3.0
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
          # @since 0.3.0
          #
          # @see #file
          #
          # @api public
          #
          def files(paths,conditions={})
            paths.each do |remote_path,local_path|
              file(remote_path,local_path)
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
          # @since 0.2.0
          #
          # @api public
          #
          def directory(remote_path,local_path,conditions={})
            dir = Rack::File.new(local_path)

            get("#{remote_path}/*",conditions) do |sub_path|
              dir.call(env.merge('PATH_INFO' => sub_path))
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
          # @since 0.3.0
          #
          # @see #directory
          #
          # @api public
          #
          def directories(paths,conditions={},&block)
            paths.each do |remote_path,local_path|
              directory(remote_path,local_path)
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
          # @since 0.2.0
          #
          # @api public
          #
          def public_dir(path,conditions={})
            directory('/',path,conditions)
          end

          #
          # Routes all requests within a given directory into another
          # web server.
          #
          # @param [String] dir
          #   The directory that requests for will be routed from.
          #
          # @param [#call] server
          #   The web server to route requests to.
          #
          # @param [Hash{Symbol => Object}] conditions
          #   Additional routing conditions.
          #
          # @example
          #   route '/subapp/', SubApp
          #
          # @since 1.0.0
          #
          # @api public
          #
          def route(dir,server,conditions={})
            any("#{dir}/?*",conditions) do |sub_path|
              server.call(env.merge('PATH_INFO' => sub_path))
            end
          end

          #
          # Proxies requests to a given path.
          #
          # @param [String] path
          #   The path to proxy requests for.
          #
          # @param [Hash{Symbol => Object}] conditions
          #   Additional routing conditions.
          #
          # @yield [proxy]
          #   The block will be passed the new proxy instance.
          #
          # @yieldparam [Proxy] proxy
          #   The new proxy to configure.
          #
          # @example
          #   proxy '/login.php' do |proxy|
          #     proxy.on_response do |response|
          #       response.body.gsub(/https/,'http')
          #     end
          #   end
          #
          # @see Proxy
          #
          # @since 0.2.0
          #
          # @api public
          #
          def proxy(path='*',conditions={},&block)
            proxy = Proxy.new(&block)

            any(path,conditions) { proxy.call(env) }
          end

          protected

          #
          # Condition to match the IP Address that sent the request.
          #
          # @param [IPAddr, String] ip
          #   The IP address or range of addresses to match against.
          #
          # @since 1.0.0
          #
          # @api semipublic
          #
          def ip_address(ip)
            ip = IPAddr.new(ip.to_s) unless ip.kind_of?(IPAddr)

            condition { ip.include?(request.ip) }
          end

          #
          # Condition to match the `Referer` header of the request.
          #
          # @param [Regexp, String] pattern
          #   Regular expression or exact Referer to match against.
          #
          # @since 1.0.0
          #
          # @api semipublic
          #
          def referer(pattern)
            condition do
              case pattern
              when Regexp
                request.referer =~ pattern
              else
                request.referer == pattern
              end
            end
          end

          #
          # Condition to match requests sent by an IP Address targeted by a
          # Campaign.
          #
          # @param [String] name
          #   The name of the Campaign to match IP Addresses against.
          #
          # @since 1.0.0
          #
          # @api semipublic
          #
          def campaign(name)
            condition do
              Target.first(
                'campaign.name'   => name,
                'address.address' => request.ip
              )
            end
          end
        end

        #
        # Returns the MIME type for a path.
        #
        # @param [String] path
        #   The path to determine the MIME type for.
        #
        # @return [String]
        #   The MIME type for the path.
        #
        # @since 0.3.0
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
        # @since 0.3.0
        #
        # @api public
        #
        def content_type_for(path)
          content_type mime_type_for(path)
        end

        alias h escape_html
        alias file send_file

      end
    end
  end
end
