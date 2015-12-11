module Users
  # Customization for Devise RegistrationsController
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_permitted_parameters

    protected

    def update_resource(resource, params)
      resource.person.update_attributes(params[:person]) if resource.person
      resource.update_without_password(params.except(:person))
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up).push(:name, :email, :twitter_username)
      devise_parameter_sanitizer.for(:account_update).push(:name, :email, person: [:tshirt_size, :tshirt_size_other])
    end
  end
end
