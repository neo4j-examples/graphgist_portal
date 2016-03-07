require 'rails_helper'

RSpec.describe 'Live Graphgists', type: :request do
  use_vcr_cassette 'live_graphgists', record: :new_episodes

  before { delete_dbs }

  describe 'GET /live_graphgists.json' do
    subject do
      get('/live_graphgists.json')
      expect(response).to have_http_status(200)
      json_response_body
    end
  end
end
