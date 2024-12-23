class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  # def devise_controller?
  #   self.class < Devise::SessionsController || self.class < Devise::RegistrationsController || self.class < Devise::PasswordsController
  # end
  def after_sign_in_path_for(resource)
    posts_path # after log in navigate to the index page
  end 

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone_number])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone_number])
  end
end
