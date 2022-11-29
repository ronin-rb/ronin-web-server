# ronin-web-server

[![CI](https://github.com/ronin-rb/ronin-web-server/actions/workflows/ruby.yml/badge.svg)](https://github.com/ronin-rb/ronin-web-server/actions/workflows/ruby.yml)
[![Code Climate](https://codeclimate.com/github/ronin-rb/ronin-web-server.svg)](https://codeclimate.com/github/ronin-rb/ronin-web-server)

* [Website](https://ronin-rb.dev/)
* [Source](https://github.com/ronin-rb/ronin-web-server)
* [Issues](https://github.com/ronin-rb/ronin-web-server/issues)
* [Documentation](https://ronin-rb.dev/docs/ronin-web-server/frames)
* [Slack](https://ronin-rb.slack.com) |
  [Discord](https://discord.gg/6WAb3PsVX9) |
  [Twitter](https://twitter.com/ronin_rb)

## Description

ronin-web-server is a custom Ruby web server based on Sinatra tailored for
security research and development.

## Features

* Provides a [Sinatra][sinatra] based
  {Ronin::Web::Server::Base web server base class}.
* Supports additional routing helper methods:
  * `any` - matches any HTTP request method.
  * `default` - default response for the app.
  * `basic_auth` - enables Basic-Auth for the app.
  * `redirect` - adds a redirect to a given URL for the given path.
  * `file` - mounts a local file to the given path.
  * `directory` - mounts a local directory of files at the given path.
  * `public_dir` - mounts the files/directories within the directory to the root
    of the app.
  * `vhost` - routes all requests for the given host to another app.
  * `mount` - routes all requests for a given directory to another app.
* Supports additional routing conditions:
  * `client_ip` - matches the client IP Address that sent the request.
  * `asn` - matches the AS number of the client's IP address.
  * `country_code` - matches the country code of the ASN information for the
    client's IP address.
  * `asn_name` - matches the company/ISP name of the ASN information for the
    client's IP address.
  * `host` - matches the `Host` header.
  * `referer` - matches the `Referer` header of the request.
  * `user_agent` - matches the `User-Agent` header of the request.
  * `browser` - matches the browser name from the `User-Agent` header of the
    request.
  * `browser_vendor` - matches the browser vendor from the `User-Agent` header
    of the request.
  * `browser_version` - matches the browser version from the `User-Agent` header
    of the request.
  * `device_type` - matches the device type of the `User-Agent` header of the
    request.
  * `os` - matches the OS from the `User-Agent` header of the request.
  * `os_version` - matches the OS version from the `User-Agent` header of the
    request.
* Has 97% documentation coverage.
* Has 85% test coverage.

## Examples

Create and run a simple web app:

```ruby
require 'ronin/web/server'

class App < Ronin::Web::Server::Base

  # mount a file
  file '/sitemap.xml', './files/sitemap.xml'

  # mount a directory
  directory '/downloads/', '/tmp/downloads/'

  get '/' do
    # renders views/index.erb
    erb :index
  end

  get '/test' do
    "raw string here"
  end

  get '/exploit', asn: 13335 do
    # route that only matches the AS13335 netblock
  end

  get '/exploit', asn_name: 'GOOGLE' do
    # route that only matches GOOGLE netblocks
  end

  get '/exploit', country_code: 'US' do
    # route that only matches US netblocks
  end

  get '/exploit', browser: :firefox do
    # route that only matches firefox web browsers
  end

  get '/exploit', browser: :chrome, browser_version: /^99\./ do
    # route that only matches chrome 99.X.Y.Z web browsers
  end

  get '/exploit', os: :ios, os_version: '15.6' do
    # route that only matches iOS 15.6 devices
  end

  # catchall route
  get '/exploit' do
    "nothing to see here"
  end

end

App.run!
```

**Note**: See {Ronin::Web::Server::Base} and [Sinatra's Intro][1] for additional
documentation.

[1]: http://sinatrarb.com/intro.html

## Requirements

* [Ruby] >= 3.0.0
* [webrick] ~> 1.0
* [rack] ~> 1.3
* [rack-user_agent] ~> 0.5
* [sinatra] ~> 1.3
* [ronin-support] ~> 1.0

## Install

```shell
$ gem install ronin-web-server
```

### Gemfile

```shell
gem 'ronin-web-server', '~> 0.1'
```

## Development

1. [Fork It!](https://github.com/ronin-rb/ronin-web-server/fork)
2. Clone It!
3. `cd ronin-web-server/`
4. `bundle install`
5. `git checkout -b my_feature`
6. Code It!
7. `bundle exec rake spec`
8. `git push origin my_feature`

## License

ronin-web-server - A custom Ruby web server based on Sinatra.

Copyright (c) 2006-2022 Hal Brodigan (postmodern.mod3 at gmail.com)

ronin-web-server is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ronin-web-server is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with ronin-web-server.  If not, see <https://www.gnu.org/licenses/>.

[Ruby]: https://www.ruby-lang.org
[webrick]: https://github.com/ruby/webrick#readme
[rack]: https://github.com/rack/rack#readme
[rack-user_agent]: https://github.com/k0kubun/rack-user_agent#readme
[sinatra]: https://github.com/sinatra/sinatra#readme
[ronin-support]: https://github.com/ronin-rb/ronin-support#readme
