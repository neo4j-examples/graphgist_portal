module Users
  class SessionsController < Devise::SessionsController

    def destroy
      sign_out
      redirect_to logout_url.to_s
    end

    private

    def logout_url
      domain = ENV['AUTH0_DOMAIN']
      request_params = {
          returnTo: root_url,
          client_id: ENV['AUTH0_CLIENT_ID']
      }

      URI::HTTPS.build(host: domain, path: '/logout', query: to_query(request_params))
    end

    def to_query(hash)
      hash.map {|k, v| "#{k}=#{URI.escape(v)}" unless v.nil?}.reject(&:nil?).join('&')
    end
  end
end