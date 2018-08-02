require 'omniauth-oauth2'
require 'omniauth-auth0'

module OmniAuth  
  module Strategies
    class Authtoken < OmniAuth::Strategies::Auth0
      include OmniAuth::Strategy
      option :name, 'authtoken'

      def build_access_token
        if request.params.has_key?("access_token")
          return ::OAuth2::AccessToken.from_hash(client, {
            access_token: request.params["access_token"],
            state: request.params["state"],
            token_type: request.params["token_type"],
            expires_in: request.params["expires_in"]
          })
        else
          verifier = request.params["code"]
          return client.auth_code.get_token(verifier, {:redirect_uri => callback_url}.merge(token_params.to_hash(:symbolize_keys => true)), deep_symbolize(options.auth_token_params))
        end
      end
    end
  end
end