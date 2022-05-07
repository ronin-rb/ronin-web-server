require 'spec_helper'
require 'ronin/web/server/request'

describe Ronin::Web::Server::Request do
  let(:env) { {} }

  subject { described_class.new(env) }

  describe "#address" do
    let(:ip) { '127.0.0.1' }

    context "when REMOTE_PORT is set" do
      let(:port) { 8000 }
      let(:env) do
        {'REMOTE_ADDR' => ip, 'REMOTE_PORT' => port}
      end

      it "must return REMOTE_ADDR:REMOTE_PORT" do
        expect(subject.address).to eq("#{ip}:#{port}")
      end
    end

    context "when REMOTE_PORT is not set" do
      let(:env) do
        {'REMOTE_ADDR' => ip}
      end

      it "must return the REMOTE_ADDR" do
        expect(subject.address).to eq("#{ip}")
      end
    end
  end

  describe "#headers" do
    let(:header1) { 'header1 value' }
    let(:header2) { 'header2 value' }
    let(:env) do
      {
        'HTTP_HEADER1' => header1,
        'FOO_BAR'      => 'foo',
        'HTTP_HEADER2' => header2
      }
    end

    it "must return a Hash of all HTTP_* headers" do
      expect(subject.headers).to eq(
        {
          'Header1' => header1,
          'Header2' => header2
        }
      )
    end
  end
end
