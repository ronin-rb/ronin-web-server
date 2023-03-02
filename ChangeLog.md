### 0.1.1 / 2023-03-01

* Correctly set the `bind` setting in {Ronin::Web::Server::Base} to ensure it
  will always listen on `0.0.0.0`.
* Allow `directory` and `mount` to accept directory paths ending with a `/`.
* Increased test coverage.

### 0.1.0 / 2023-02-01

* Extracted and refactored from [ronin-web](https://github.com/ronin-rb/ronin-web/tree/v0.3.0.rc1).
* Relicensed as LGPL-3.0.
* Initial release:
  * Requires `ruby` >= 3.0.0.
  * Provides a [Sinatra][sinatra] based
    {Ronin::Web::Server::Base web server base class}.
  * Supports additional routing helper methods:
    * `any` - matches any HTTP request method.
    * `default` - default response for the app.
    * `basic_auth` - enables Basic-Auth for the app.
    * `redirect` - adds a redirect to a given URL for the given path.
    * `file` - mounts a local file to the given path.
    * `directory` - mounts a local directory of files at the given path.
    * `public_dir` - mounts the files/directories within the directory to the
      root of the app.
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
    * `browser_version` - matches the browser version from the `User-Agent`
      header of the request.
    * `device_type` - matches the device type of the `User-Agent` header of the
      request.
    * `os` - matches the OS from the `User-Agent` header of the request.
    * `os_version` - matches the OS version from the `User-Agent` header of the
      request.

