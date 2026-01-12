require 'rack/test'

module Helpers
  module Web
    module RackApp
      include Rack::Test::Methods

      DEFAULT_HEADERS = {
        'HTTP_HOST' => 'localhost'
      }

      attr_reader :app

      def app=(server)
        @app = server
        @app.set :environment, :test
      end

      def get(path,params={},headers={})
        super(path,params,DEFAULT_HEADERS.merge(headers))
      end

      def post(path,params={},headers={})
        super(path,params,DEFAULT_HEADERS.merge(headers))
      end

      def put(path,params={},headers={})
        super(path,params,DEFAULT_HEADERS.merge(headers))
      end

      def patch(path,params={},headers={})
        super(path,params,DEFAULT_HEADERS.merge(headers))
      end

      def delete(path,params={},headers={})
        super(path,params,DEFAULT_HEADERS.merge(headers))
      end

      def options(path,params={},headers={})
        super(path,params,DEFAULT_HEADERS.merge(headers))
      end
    end
  end
end
