require 'spec_helper'
require 'ronin/web/server/routing'

require 'helpers/rack_app'
require 'sinatra/base'

describe Ronin::Web::Server::Routing do
  include Helpers::Web::RackApp

  describe ".any" do
    module TestRouting
      class TestAny < Sinatra::Base
        include Ronin::Web::Server::Routing

        any '/test' do
          'test any route'
        end
      end
    end

    let(:app) { TestRouting::TestAny }

    it "must match GET requests" do
      get '/test'

      expect(last_response).to be_ok
      expect(last_response.body).to eq('test any route')
    end

    it "must match POST requests" do
      post '/test'

      expect(last_response).to be_ok
      expect(last_response.body).to eq('test any route')
    end

    it "must match PUT requests" do
      put '/test'

      expect(last_response).to be_ok
      expect(last_response.body).to eq('test any route')
    end

    it "must match PATCH requests" do
      patch '/test'

      expect(last_response).to be_ok
      expect(last_response.body).to eq('test any route')
    end

    it "must match DELETE requests" do
      delete '/test'

      expect(last_response).to be_ok
      expect(last_response.body).to eq('test any route')
    end

    it "must match OPTIONS requests" do
      options '/test'

      expect(last_response).to be_ok
      expect(last_response.body).to eq('test any route')
    end
  end

  describe ".default" do
    module TestRouting
      class TestDefault < Sinatra::Base
        include Ronin::Web::Server::Routing

        get '/test' do
          'test'
        end

        default do
          halt 200, 'default route'
        end
      end
    end

    let(:app) { TestRouting::TestDefault }

    it "must still route requests to other routes" do
      get '/test'

      expect(last_response).to be_ok
      expect(last_response.body).to eq('test')
    end

    it "must route any other request to the default block" do
      get '/foo'

      expect(last_response).to be_ok
      expect(last_response.body).to eq('default route')
    end
  end

  describe ".basic_auth" do
    module TestRouting
      class TestBasicAuth < Sinatra::Base
        include Ronin::Web::Server::Routing

        basic_auth 'admin', 's3cr3t'

        get '/test' do
          'test'
        end
      end
    end

    let(:app) { TestRouting::TestBasicAuth }

    it "must add Basic-Auth protection to the app" do
      get '/test'

      expect(last_response.status).to be(401)

      basic_authorize 'admin', 's3cr3t'
      get '/test'

      expect(last_response).to be_ok
      expect(last_response.body).to eq('test')
    end
  end

  describe ".redirect" do
    module TestRouting
      class TestRedirect < Sinatra::Base
        include Ronin::Web::Server::Routing

        redirect '/test', 'https://example.com/'
      end
    end

    let(:app) { TestRouting::TestRedirect }

    it "must return a 302 redirect with the given URL" do
      get '/test'

      expect(last_response.status).to be(302)
      expect(last_response.location).to eq('https://example.com/')
    end
  end

  let(:fixtures_dir) { File.join(__dir__,'fixtures') }

  describe ".file" do
    module TestRouting
      class TestFile < Sinatra::Base
        include Ronin::Web::Server::Routing

        file '/test', File.join(__dir__,'fixtures','file1.txt')
      end
    end

    let(:app) { TestRouting::TestFile }

    it "must return the body of the mounted file" do
      get '/test'

      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        File.read(File.join(fixtures_dir,'file1.txt'))
      )
    end
  end

  describe ".directory" do
    module TestRouting
      class TestDirectory < Sinatra::Base
        include Ronin::Web::Server::Routing

        directory '/test', File.join(__dir__,'fixtures','dir')
      end
    end

    let(:app) { TestRouting::TestDirectory }

    context "when the requested path maps to a file within the directory" do
      it "must return the body of the file within the directory" do
        get '/test/file1.txt'

        expect(last_response).to be_ok
        expect(last_response.body).to eq(
          File.read(File.join(fixtures_dir,'dir','file1.txt'))
        )
      end
    end

    context "when the requested path contains '../'" do
      it "must not allow escaping the directory" do
        get '/test/../file1.txt'

        expect(last_response).to_not be_ok
        expect(last_response.body).to_not eq(
          File.read(File.join(fixtures_dir,'file1.txt'))
        )
      end
    end

    context "when the exposed directory ends with a '/'" do
      module TestRouting
        class TestDirectoryWithTrailingSlash < Sinatra::Base
          include Ronin::Web::Server::Routing

          directory '/test/', File.join(__dir__,'fixtures','dir')
        end
      end

      let(:app) { TestRouting::TestDirectoryWithTrailingSlash }

      it "must omit the trailing '/' from the final route" do
        get '/test/file1.txt'

        expect(last_response).to be_ok
        expect(last_response.body).to eq(
          File.read(File.join(fixtures_dir,'dir','file1.txt'))
        )
      end
    end
  end

  describe ".public_dir" do
    module TestRouting
      class TestPublicDir < Sinatra::Base
        include Ronin::Web::Server::Routing

        public_dir File.join(__dir__,'fixtures')
      end
    end

    let(:app) { TestRouting::TestPublicDir }

    it "must expose the files within the public directory" do
      get '/file1.txt'

      expect(last_response).to be_ok
      expect(last_response.body).to eq(
        File.read(File.join(fixtures_dir,'file1.txt'))
      )
    end
  end

  describe ".vhost" do
    module TestRouting
      class VHostApp < Sinatra::Base

        get '/test' do
          'example.com app'
        end

      end

      class TestVHost < Sinatra::Base
        include Ronin::Web::Server::Routing

        vhost 'example.com', VHostApp

        get '/test' do
          'main app'
        end
      end
    end

    let(:vhost_app) { TestRouting::VHostApp }
    let(:app)       { TestRouting::TestVHost }

    context "when the host authorization of the app is enabled" do
      module TestRouting
        class TestVHostWithPermittedHosts < Sinatra::Base
          include Ronin::Web::Server::Routing

          set :host_authorization, {permitted_hosts: %w[localhost]}

          vhost 'example.com', VHostApp

          get '/test' do
            'main app'
          end
        end
      end

      let(:app) { TestRouting::TestVHostWithPermittedHosts }

      it "must add the vhost name to the app's phost_authorization[:ermitted_hosts]" do
        permitted_hosts = app.host_authorization[:permitted_hosts]

        expect(permitted_hosts).to include('example.com')
      end
    end

    context "when the host authorization of the app is disabled" do
      module TestRouting
        class TestVHostWithoutPermittedHosts < Sinatra::Base
          include Ronin::Web::Server::Routing

          set :host_authorization, {}

          vhost 'example.com', VHostApp

          get '/test' do
            'main app'
          end
        end
      end

      let(:app) { TestRouting::TestVHostWithoutPermittedHosts }

      it "must not change host_authorization[:permitted_hosts]" do
        permitted_hosts = app.host_authorization[:permitted_hosts]

        expect(permitted_hosts).to be(nil)
      end
    end

    context "when the host authorization of the destination app is enabled" do
      module TestRouting
        class VHostAppWithPermittedHosts < Sinatra::Base
          set :host_authorization, {permitted_hosts: %w[localhost]}

          get '/test' do
            'example.com app'
          end
        end

        class TestVHostWithPermittedHosts < Sinatra::Base
          include Ronin::Web::Server::Routing

          vhost 'example.com', VHostAppWithPermittedHosts

          get '/test' do
            'main app'
          end
        end
      end

      let(:vhost_app) { TestRouting::VHostAppWithPermittedHosts }
      let(:app)       { TestRouting::TestVHostWithPermittedHosts }

      it "must add the vhost name to the destination app's host_authorization[:permitted_hosts]" do
        permitted_hosts = vhost_app.host_authorization[:permitted_hosts]

        expect(permitted_hosts).to include('example.com')
      end
    end

    context "when the host authorization of the destination app is disabled" do
      module TestRouting
        class VHostAppWithoutPermittedHosts < Sinatra::Base
          set :host_authorization, {}

          set :environment, :test

          get '/test' do
            'example.com app'
          end
        end

        class TestVHostWithoutPermittedHosts < Sinatra::Base
          include Ronin::Web::Server::Routing

          vhost 'example.com', VHostAppWithoutPermittedHosts

          get '/test' do
            'main app'
          end
        end
      end

      let(:vhost_app) { TestRouting::VHostAppWithoutPermittedHosts }
      let(:app)       { TestRouting::TestVHostWithoutPermittedHosts }

      it "must not change host_authorization[:permitted_hosts]" do
        permitted_hosts = vhost_app.host_authorization[:permitted_hosts]

        expect(permitted_hosts).to be(nil)
      end
    end

    context "when the request has the matching Host: header set" do
      it "must route the request to the other app" do
        get '/test', {}, {'HTTP_HOST' => 'example.com'}

        expect(last_response).to be_ok
        expect(last_response.body).to eq('example.com app')
      end
    end

    context "when the request does not have the matching Host: header set" do
      it "must return a response from the main app" do
        get '/test'

        expect(last_response).to be_ok
        expect(last_response.body).to eq('main app')
      end
    end
  end

  describe ".mount" do
    module TestRouting
      class SubApp < Sinatra::Base

        get '/' do
          'sub-app root'
        end

        get '/test' do
          'sub-app'
        end

      end

      class TestMountedApp < Sinatra::Base
        include Ronin::Web::Server::Routing

        mount '/sub', SubApp

        get '/test' do
          'main app'
        end
      end
    end

    let(:app) { TestRouting::TestMountedApp }

    context "when the request has the matching directory prefix" do
      it "must route the request to the other app" do
        get '/sub/test'

        expect(last_response).to be_ok
        expect(last_response.body).to eq('sub-app')
      end

      context "when the request is for the sub-apps root route" do
        it "must route the request to the sub-app's '/' route" do
          get '/sub'

          expect(last_response).to be_ok
          expect(last_response.body).to eq('sub-app root')
        end
      end
    end

    context "when the request does not have the matching directory prefix" do
      it "must return a response from the main app" do
        get '/test'

        expect(last_response).to be_ok
        expect(last_response.body).to eq('main app')
      end
    end

    context "when the exposed directory ends with a '/'" do
      module TestRouting
        class TestMountWithTrailingSlash < Sinatra::Base
          include Ronin::Web::Server::Routing

          mount '/sub/', SubApp
        end
      end

      let(:app) { TestRouting::TestMountWithTrailingSlash }

      it "must omit the trailing '/' from the final route" do
        get '/sub/test'

        expect(last_response).to be_ok
        expect(last_response.body).to eq('sub-app')
      end
    end
  end
end
