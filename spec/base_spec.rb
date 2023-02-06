require 'spec_helper'
require 'ronin/web/server/base'

require 'helpers/rack_app'

describe Ronin::Web::Server::Base do
  include Helpers::Web::RackApp

  describe "DEFAULT_HOST" do
    it "must equal '0.0.0.0'" do
      expect(described_class::DEFAULT_HOST).to eq('0.0.0.0')
    end
  end

  describe "DEFAULT_PORT" do
    it "must equal 8000" do
      expect(described_class::DEFAULT_PORT).to eq(8000)
    end
  end

  describe "settings" do
    it "must default the bind to DEFAULT_HOST" do
      expect(described_class.bind).to eq(described_class::DEFAULT_HOST)
    end

    it "must default the port to DEFAULT_PORT" do
      expect(described_class.port).to eq(described_class::DEFAULT_PORT)
    end
  end

  describe "not_found" do
    module TestBaseServer
      class TestNotFound < Ronin::Web::Server::Base
      end
    end

    let(:app) { TestBaseServer::TestNotFound }

    it "must default to returning an empty 404 response" do
      get '/does/not/exist'

      expect(last_response.status).to be(404)
      expect(last_response.body).to eq('')
    end
  end
end
