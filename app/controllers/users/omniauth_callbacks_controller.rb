module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def auth0
      auth = env['omniauth.auth']
      # Rails.logger.info("auth is **************** #{auth.to_yaml}")
      provider, uid = auth['uid'].split('|')
      @user = User.find_by_provider_and_uid(provider, uid) || User.find_by(email: auth['info']['email']) || User.from_omniauth(auth)
      flash[:notice] = 'Successfully authenticated.'
      sign_in_and_redirect @user, event: :authentication
    end
  end
end
