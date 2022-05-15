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
* Provides a [Rack][rack] compatible {Ronin::Web::Server::Proxy proxy server}.

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

This file is part of ronin-web-server.

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
[sinatra]: https://github.com/sinatra/sinatra#readme
[ronin-support]: https://github.com/ronin-rb/ronin-support#readme
