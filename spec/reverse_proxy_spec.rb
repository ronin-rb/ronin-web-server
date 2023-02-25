require 'spec_helper'
require 'ronin/web/server/reverse_proxy'

require 'webmock/rspec'

describe Ronin::Web::Server::ReverseProxy do
  describe "#initialize" do
    context "when given a block" do
      it "must pass the newly created reverse proxy object" do
        expect { |b|
          described_class.new(&b)
        }.to yield_with_args(described_class)
      end
    end
  end

  describe "#call" do
    let(:request_method) { 'GET' }
    let(:path) { '/' }
    let(:port) { 80  }
    let(:host) { 'example.com' }
    let(:body) { '' }
    let(:env) do
      {
        'REQUEST_METHOD' => request_method,
        'REQUEST_PATH'   => path,
        'PATH_INFO'      => path,
        'HTTP_HOST'      => host,
        'SERVER_PORT'    => port,
        'rack.input'     => StringIO.new(body)
      }
    end

    let(:http_request_method) { request_method.downcase.to_sym }
    let(:http_request_uri) do
      URI::HTTP.build(host: host, port: port, path: path)
    end

    let(:http_response_status) { 200 }
    let(:http_response_headers) do
      {'X-Foo' => 'bar'}
    end
    let(:http_response_body) { nil }

    before do
      stub_request(:get,http_request_uri).to_return(
        status:  http_response_status,
        headers: http_response_headers,
        body:    http_response_body
      )
    end

    it "must return a Rack response tuple (status, headers, body)" do
      response = subject.call(env)

      expect(response).to be_kind_of(Array)
      expect(response[0]).to be_kind_of(Integer)
      expect(response[1]).to be_kind_of(Hash)
      expect(response[2]).to be_kind_of(Array)
    end

    it "must make an HTTP request for the requested Host header and path" do
      subject.call(env)

      expect(WebMock).to have_requested(http_request_method,http_request_uri)
    end

    it "must return all HTTP response headers in the respones object" do
      _status, headers, _body = subject.call(env)

      expect(headers).to include(http_response_headers)
    end

    it "must default the response body to an empty String" do
      _status, _headers, body = subject.call(env)

      expect(body).to eq([''])
    end

    context "when the #on_request callback is set" do
      it "must pass the request object to the #on_request callback" do
        yielded_request = nil

        reverse_proxy = described_class.new do |proxy|
          proxy.on_request do |request|
            yielded_request = request
          end
        end

        reverse_proxy.call(env)

        expect(yielded_request).to be_kind_of(described_class::Request)
      end
    end

    context "when the #on_response callback is set" do
      it "must pass the response object to the #on_response callback" do
        yielded_response = nil

        reverse_proxy = described_class.new do |proxy|
          proxy.on_response do |response|
            yielded_response = response
          end
        end

        reverse_proxy.call(env)

        expect(yielded_response).to be_kind_of(described_class::Response)
      end

      context "when the #on_response callback accepts two arguments" do
        it "must pass both the request and the response objects" do
          yielded_request  = nil
          yielded_response = nil

          reverse_proxy = described_class.new do |proxy|
            proxy.on_response do |request,response|
              yielded_request  = request
              yielded_response = response
            end
          end

          reverse_proxy.call(env)

          expect(yielded_request).to be_kind_of(described_class::Request)
          expect(yielded_response).to be_kind_of(described_class::Response)
        end
      end
    end
  end

  describe "#connection_for" do
    let(:host) { 'example.com' }
    let(:port) { 443  }
    let(:ssl)  { true }

    context "when there is no connection for the host/port/ssl combination" do
      it "must return a new Ronin::Support::Network::HTTP instance for the host/port/ssl combination" do
        http = subject.connection_for(host,port,ssl: ssl)

        expect(http).to be_kind_of(Ronin::Support::Network::HTTP)
        expect(http.host).to eq(host)
        expect(http.port).to eq(port)
        expect(http.ssl?).to eq(ssl)
      end
    end

    context "when there is an existing connection for the host/port/ssl combination" do
      it "must return the existing Ronin::Support::Network::HTTP instance for the host/port/ssl combination" do
        expect(subject.connection_for(host,port,ssl: ssl)).to be(
          subject.connection_for(host,port,ssl: ssl)
        )
      end
    end
  end

  describe "#reverse_proxy" do
    let(:request_method) { 'GET' }
    let(:path) { '/' }
    let(:port) { 80  }
    let(:host) { 'example.com' }
    let(:body) { '' }
    let(:env) do
      {
        'REQUEST_METHOD' => request_method,
        'REQUEST_PATH'   => path,
        'PATH_INFO'      => path,
        'HTTP_HOST'      => host,
        'SERVER_PORT'    => port,
        'rack.input'     => StringIO.new(body)
      }
    end
    let(:request) { described_class::Request.new(env) }

    let(:http_request_method) { request_method.downcase.to_sym }
    let(:http_request_uri) do
      URI::HTTP.build(host: host, port: port, path: path)
    end

    let(:http_response_status) { 200 }
    let(:http_response_headers) do
      {'X-Foo' => 'bar'}
    end
    let(:http_response_body) { nil }

    before do
      stub_request(:get,http_request_uri).to_return(
        status:  http_response_status,
        headers: http_response_headers,
        body:    http_response_body
      )
    end

    it "must return a #{described_class::Response} object" do
      expect(subject.reverse_proxy(request)).to be_kind_of(described_class::Response)
    end

    it "must make an HTTP request for the requested Host header and path" do
      subject.reverse_proxy(request)

      expect(WebMock).to have_requested(http_request_method,http_request_uri)
    end

    it "must return all HTTP response headers in the respones object" do
      response = subject.reverse_proxy(request)

      expect(response.headers).to include(http_response_headers)
    end

    it "must default the response body to an empty String" do
      response = subject.reverse_proxy(request)

      expect(response.body).to eq([''])
    end

    context "when the response contains the 'Transfer-Encoding' header" do
      let(:http_response_headers) do
        {'Transfer-Encoding' => 'chunked'}
      end

      it "must omit the 'Transfer-Encoding' header from the response" do
        response = subject.reverse_proxy(request)

        expect(response.headers).to_not have_key('Transfer-Encoding')
      end
    end
  end
end
