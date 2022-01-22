require 'rspec'
require 'simplecov'
require 'ronin/web/server/version'

SimpleCov.start

RSpec.configure do |c|
  c.include Ronin::Web::Server
end
