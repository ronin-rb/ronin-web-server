require 'rack/test'

module Helpers
  module Web
    module RackApp
      include Rack::Test::Methods

      attr_reader :app

      def app=(server)
        @app = server
        @app.set :environment, :test
      end
    end
  end
end
