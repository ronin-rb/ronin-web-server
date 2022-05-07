require 'spec_helper'
require 'ronin/web/server/response'

describe Ronin::Web::Server::Response do
  it "must provide the same methods as Sinatra::Response" do
    expect(described_class).to be < Sinatra::Response
  end
end
