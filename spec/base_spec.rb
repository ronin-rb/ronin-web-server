require 'spec_helper'
require 'ronin/web/server/base'

require 'classes/test_app'
require 'helpers/rack_app'

describe Ronin::Web::Server::Base do
  include Helpers::Web::RackApp

  before(:all) do
    self.app = TestApp
  end

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
    it "must default the host to DEFAULT_HOST" do
      expect(described_class.host).to eq(described_class::DEFAULT_HOST)
    end

    it "must default the port to DEFAULT_PORT" do
      expect(described_class.port).to eq(described_class::DEFAULT_PORT)
    end
  end

  it "must still bind blocks to paths" do
    get '/tests/get'

    expect(last_response).to be_ok
    expect(last_response.body).to eq('block tested')
  end

  it "must bind a block to a path for all request types" do
    post '/tests/any'

    expect(last_response).to be_ok
    expect(last_response.body).to eq('any tested')
  end

  it "must have a default response" do
    get '/totally/non/existant/path'

    expect(last_response).not_to be_ok
    expect(last_response.body).to be_empty
  end

  it "must allow for defining custom responses" do
    TestApp.default do
      halt 404, 'nothing to see here'
    end

    get '/whats/here'

    expect(last_response).not_to be_ok
    expect(last_response.body).to eq('nothing to see here')
  end

  it "must map paths to sub-apps" do
    get '/tests/subapp/'

    expect(last_response).to be_ok
    expect(last_response.body).to eq('SubApp')
  end

  it "must not modify the path_info as it maps paths to sub-apps" do
    get '/tests/subapp/hello'

    expect(last_response).to be_ok
    expect(last_response.body).to eq('SubApp greets you')
  end

  it "must host static content from public directories" do
    get '/static1.txt'

    expect(last_response).to be_ok
    expect(last_response.body).to eq("Static file1.\n")
  end

  it "must host static content from multiple public directories" do
    get '/static2.txt'

    expect(last_response).to be_ok
    expect(last_response.body).to eq("Static file2.\n")
  end
end
