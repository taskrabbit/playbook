require 'spec_helper'

describe "Playbook Batching" do
  include Playbook::Spec::RequestHelper

  class BatchController < Playbook::BaseController

    def ok
      head :ok
    end

    def fourohfour
      head 404
    end

    def jsoncontent
      render :json => {'my' => 'content'}
    end

    def paramcheck
      render :json => params.except(:controller, :action, :format, :version).merge(:method => request.method)
    end
  end

  before do
    Playbook.configure do |c|
      c.batch_path = '/api/batch.json'
    end

    authorize!(external_client_app)
  end

  it 'should conduct multiple operations and return the response content' do
    requests = [
      {
        :path => '/api/v2/test/batch/ok.json'
      },
      {
        :path => '/api/v2/test/batch/fourohfour.json'
      },
      {
        :path => '/api/v2/test/batch/jsoncontent.json'
      },
      {
        :path => '/api/v2/test/batch/paramcheck.json',
        :params => {
          :page => 2
        },
        :method => 'post'
      }
    ]

    post '/api/batch.json', requests.to_json, headers

    response.code.should eql('200')

    json.length.should eql(4)

    json[0]['status'].should eql(200)
    json[1]['status'].should eql(404)
    json[2]['body'].should eql({'my' => 'content'})
    json[3]['body'].should eql({'page' => '2', 'method' => 'POST'})

  end

end