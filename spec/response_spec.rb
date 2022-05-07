require 'spec_helper'
require 'ronin/web/server/response'

describe Ronin::Web::Server::Response do
  it { expect(described_class).to be < Sinatra::Response }
end
