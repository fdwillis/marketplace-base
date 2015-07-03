class ApplicationController < ActionController::Base
  after_filter :store_location

  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

   rescue_from Pundit::NotAuthorizedError do |exception|
      redirect_to root_url, alert: exception.message
    end

  def store_location
    # store last url as long as it isn't a /users path
    session[:previous_url] = request.fullpath unless request.fullpath =~ /\/users/
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end
  
   protected
 
   def configure_permitted_parameters
     devise_parameter_sanitizer.for(:sign_up) << :username
   end
end