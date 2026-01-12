require 'spec_helper'
require 'ronin/web/server/helpers'

require 'sinatra/base'

describe Ronin::Web::Server::Helpers do
  module TestHelpersMixin
    class TestApp < Sinatra::Base
      include Ronin::Web::Server::Helpers
    end
  end

  subject { TestHelpersMixin::TestApp.new.helpers }

  describe "#mime_type_for" do
    it "must return the MIME Type for the given path's file extension" do
      expect(subject.mime_type_for('file.xml')).to eq('application/xml')
    end
  end

  describe "#content_type_for" do
    before do
      subject.response = Sinatra::Response.new
    end

    it "must return the Content-Type for the given path's file extension" do
      subject.content_type_for('file.xml')

      expect(subject.response['Content-Type']).to eq('application/xml;charset=utf-8')
    end
  end
end
