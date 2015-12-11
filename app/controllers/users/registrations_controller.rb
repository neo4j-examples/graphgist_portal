module Users
  # Customization for Devise RegistrationsController
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_permitted_parameters

    protected

    def update_resource(resource, params)
      resource.update_without_password(params)
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up).push(:name, :email, :twitter_username)
    end
  end
end
