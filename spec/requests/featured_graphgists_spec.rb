require 'rails_helper'

RSpec.describe "Featured Graphgists", type: :request do
  use_vcr_cassette 'featured_graphgists', record: :new_episodes

  before { delete_dbs }

  describe "GET /featured_graphgists.json" do
    subject do
      get('/featured_graphgists.json')
      expect(response).to have_http_status(200)
      json_response_body
    end

    context 'one featured gist and one non-featured gist' do
      let!(:featured_gist) { create(:graph_gist, featured: true) }
      let!(:nonfeatured_gist) { create(:graph_gist) }

      it 'only returns featured gists' do
        expect(subject.map {|g| g[:id] }).to eq([featured_gist.id])
      end
    end
  end
end
