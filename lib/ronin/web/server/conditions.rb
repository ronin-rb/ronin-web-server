#
# ronin-web-server - A custom Ruby web server based on Sinatra.
#
# Copyright (c) 2006-2022 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require 'ronin/support/network/asn'

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
        #
        # Adds {ClassMethods} to the class.
        #
        # @param [Class] base
        #   The application base class that is including {Conditions}.
        #
        # @api private
        #
        def self.included(base)
          base.extend ClassMethods
        end

        #
        # Class methods to be added to the application base class.
        #
        module ClassMethods
          protected

          #
          # Condition to match the client IP Address that sent the request.
          #
          # @param [IPAddr, String, Proc, #===] matcher
          #   The IP address or range of addresses to match against.
          #
          # @example Only allow the exact IP:
          #   get '/path', client_ip: '10.1.1.1' do
          #     # ...
          #   end
          #
          # @example Allow all IPs from the IP range:
          #   get '/path', client_ip: IPAddr.new('10.1.1.1/24') do
          #     # ...
          #   end
          #
          def client_ip(matcher)
            condition { matcher === request.ip }
          end

          #
          # Condition to match the AS number of the client's IP address.
          #
          # @param [Integer] number
          #   The AS number to match.
          #
          # @example
          #   get '/path', asn: 13335 do
          #     # ...
          #   end
          #
          def asn(number)
            condition do
              if (record = Support::Network::ASN.query(request.ip))
                record.number == number
              end
            end
          end

          #
          # Condition to match the country code of the ASN information for the
          # client's IP address.
          #
          # @param [String] code
          #   The two letter country code to match for.
          #
          # @example
          #   get '/path', country_code: 'US' do
          #     # ...
          #   end
          #
          def country_code(code)
            condition do
              if (record = Support::Network::ASN.query(request.ip))
                record.country_code == country_code
              end
            end
          end

          #
          # Condition to match the company/ISP name of the ASN information for
          # the client's IP address.
          #
          # @param [String] name
          #   The name of the company/ISP that the ASN is assigned to.
          #
          # @example
          #   get '/path', asn_name: 'CLOUDFLARENET' do
          #     # ...
          #   end
          #
          def asn_name(name)
            condition do
              if (record = Support::Network::ASN.query(request.ip))
                record.name == name
              end
            end
          end

          #
          # Condition for matching the `Host` header.
          #
          # @param [Regexp, String, Proc, #===] matcher
          #   The host to match against.
          #
          # @example Match the exact `Host` header:
          #   get '/path', host: 'example.com' do
          #     # ...
          #   end
          #
          # @example Match any `Host` header ending in `.example.com`:
          #   get '/path', host: /\.example\.com$/ do
          #     # ...
          #   end
          #
          def host(matcher)
            condition { matcher === request.host }
          end

          #
          # Condition to match the `Referer` header of the request.
          #
          # @param [Regexp, String, Proc, #===] matcher
          #   Regular expression or exact `Referer` header to match against.
          #
          # @example Match the exact `Referer` URI:
          #   get '/path', referer: 'https://example.com/signin' do
          #     # ...
          #   end
          #
          # @example Match any `Referer` URI matching the Regexp:
          #   get '/path', referer: /^http:\/\// do
          #     # ...
          #   end
          #
          def referer(matcher)
            condition do
              if (referer = request.referer)
                matcher === referer
              end
            end
          end

          alias referrer referer

          #
          # Condition to match the `User-Agent` header of the request.
          #
          # @param [Regexp, String, Proc, #===] matcher
          #   Regular expression, exact String, Proc, or any other object which
          #   defines an `#===` method.
          #
          # @example Match any `User-Agent` with `Intel Mac OSX` in it:
          #   get '/path', user_agent: /Intel Mac OSX/ do
          #     # ...
          #   end
          #
          def user_agent(matcher)
            condition do
              if (user_agent = request.user_agent)
                matcher === user_agent
              end
            end
          end

          #
          # Condition to match the browser name from the `User-Agent` header of
          # the request.
          #
          # @param [:chrome, :firefox, Regexp, String, Proc, #===] matcher
          #   Regular expression, exact String, Proc, or any other object which
          #   defines an `#===` method.
          #
          # @example Match the exact browser name:
          #   get '/path', browser: "Foo" do
          #     # ...
          #   end
          #
          # @example Match any browser name matching the Regexp:
          #   get '/path', browser: /googlebot/i do
          #     # ...
          #   end
          #
          # @example Match all Chrome browsers:
          #   get '/path', browser: :chrome do
          #     # ...
          #   end
          #
          # @example Match all Firefox browsers:
          #   get '/path', browser: :firefox do
          #     # ...
          #   end
          #
          def browser(matcher)
            case matcher
            when :chrome
              condition { request.browser == 'Chrome' }
            when :firefox
              condition { request.browser == 'Firefox' }
            else
              condition do
                if (browser = request.browser)
                  matcher === browser
                end
              end
            end
          end

          #
          # Condition to match the browser vendor from the `User-Agent` header
          # of the request.
          #
          # @param [Regexp, String, Proc, #===] matcher
          #   Regular expression, exact String, Proc, or any other object which
          #   defines an `#===` method.
          #
          # @example Match the browser vendor:
          #   get '/path', browser_vendor: 'Google' do
          #     # ...
          #   end
          #
          def browser_vendor(matcher)
            condition do
              if (browser_vendor = request.browser_vendor)
                matcher === browser_vendor
              end
            end
          end

          #
          # Condition to match the browser version from the `User-Agent` header
          # of the request.
          #
          # @param [Array<String>, Set<String>,
          #         Regexp, String, Proc, #===] matcher
          #   Regular expression, exact String, Proc, or any other object which
          #   defines an `#===` method.
          #
          # @example Match an exact version of Chrome:
          #   get '/path', browser: :chrome, browser_version: '99.100.4844.27' do
          #     # ...
          #   end
          #
          # @example Match all Chrome versions in the 99.x version family:
          #   get '/path', browser: :chrome, browser_version: /^99\./ do
          #     # ...
          #   end
          #
          # @example Match versions of Chrome with known vulnerabilities:
          #   vuln_versions = File.readlines('chrome_versions.txt', chomp: true)
          #   
          #   get '/path', browser: :chrome, browser_version: vuln_versions do
          #     # ...
          #   end
          #
          def browser_version(matcher)
            case matcher
            when Array, Set
              condition do
                if (browser_version = request.browser_version)
                  matcher.include?(browser_version)
                end
              end
            else
              condition do
                if (browser_version = request.browser_version)
                  matcher === browser_version
                end
              end
            end
          end

          #
          # Condition to match the device type of the `User-Agent` header of
          # the request.
          #
          # @param [Array<:pc, :smartphone, :mobilephone, :appliance, :crawler>,
          #         :pc, :smartphone, :mobilephone, :appliance, :crawler,
          #         Proc, #===] matcher
          #   Array of device type Symbols, the exact devicde type Symbol,
          #   Proc, or any other object which defines an `#===` method.
          #
          # @example Match a specific device type:
          #   get '/path', device_type: :crawler do
          #     halt 404
          #   end
          #
          # @example Match multiple device types:
          #   get '/path', device_type: [:smartphone, :appliance] do
          #     # ...
          #   end
          #
          def device_type(matcher)
            condition do
              if (device_type = request.device_type)
                case matcher
                when Array then matcher.include?(device_type)
                else            matcher === device_type
                end
              end
            end
          end

          #
          # Condition to match the OS from the `User-Agent` header of the
          # request.
          #
          # @param [:android, :ios, :linux, :windows,
          #         Regexp, String, Proc, #===] matcher
          #   Regular expression, exact String, Proc, or any other object which
          #   defines an `#===` method.
          #
          # @example Match all Android devices:
          #   get '/path', os: :android do
          #     # ...
          #   end
          #
          # @example Match all iOS devices:
          #   get '/path', os: :ios do
          #     # ...
          #   end
          #
          # @example Match all Linux systems:
          #   get '/path', os: :linux do
          #     # ...
          #   end
          #
          # @example Match all Windows systems:
          #   get '/path', os: :windows do
          #     # ...
          #   end
          #
          # @example Match a specific OS:
          #   get '/path', os: 'Windows 10' do
          #     # ...
          #   end
          #
          # @example Match any OS that matches the Regexp:
          #   get '/path', os: /^Windows (?:7|8|10)/ do
          #     # ...
          #   end
          #
          def os(matcher)
            case matcher
            when :android
              condition { request.from_android_os? }
            when :ios
              condition { request.from_ios? }
            when :linux
              condition { request.os == 'Linux' }
            when :windows
              condition do
                if (os = request.os)
                  os.start_with?('Windows')
                end
              end
            else
              condition do
                if (os = request.os)
                  matcher === os
                end
              end
            end
          end

          #
          # Condition to match the OS version from the `User-Agent` header of
          # the request.
          #
          # @param [Array<String>, Set<String>,
          #         Regexp, String, Proc, #===] matcher
          #   Regular expression, exact String, Proc, or any other object which
          #   defines an `#===` method.
          #
          # @example Match a specific Android OS version:
          #   get '/path', os: :android, os_version: '8.1.0' do
          #     # ...
          #   end
          #
          # @example Match all Android OS versions that match a Regexp:
          #   get '/path', os: :android, os_version: /^8\.1\./ do
          #     # ...
          #   end
          #
          # @example Match versions of Android with known vulnerabilities:
          #   vuln_versions = File.readlines('android_versions.txt', chomp: true)
          #   
          #   get '/path', os: :android, os_version: vuln_versions do
          #     # ...
          #   end
          #
          def os_version(matcher)
            case matcher
            when Array, Set
              condition do
                if (os_version = request.os_version)
                  matcher.include?(os_version)
                end
              end
            else
              condition do
                if (os_version = request.os_version)
                  matcher === os_version
                end
              end
            end
          end
        end
      end
    end
  end
end
