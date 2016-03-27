require 'rails_helper'

RSpec.describe 'CORS header middleware', type: :request do
  describe 'GET /about' do
    before { get('/about') }

    it 'should not return CORS headers' do
      expect(response.headers).to_not have_key('Access-Control-Allow-Origin')
      expect(response.headers).to_not have_key('Access-Control-Request-Method')
    end
  end

  describe 'GET /about?test=woff2' do
    before { get('/about?test=woff2') }

    it 'should not return CORS headers' do
      expect(response.headers).to_not have_key('Access-Control-Allow-Origin')
      expect(response.headers).to_not have_key('Access-Control-Request-Method')
    end
  end

  describe 'GET /assets/semantic-ui/icons.woff2' do
    before { get(ActionController::Base.helpers.asset_path('semantic-ui/icons.woff2')) }

    it 'should not return CORS headers' do
      expect(response.headers).to match a_hash_including(
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Request-Method' => '*'
      )
    end
  end
end
