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
  protected

  def after_sign_in_path_for(resource)
    Keen.publish("Sign Ins", {
      current_user_role: current_user.role,
      current_user: current_user.id,
      current_user_ip_address: request.remote_ip,
      current_user_current_zipcode: request.location.data["zipcode"],
      current_user_current_city: request.location.data["city"] ,
      current_user_current_state: request.location.data["region_name"],
      current_user_current_country: request.location.data["country_name"],
      sign_in_year: Time.now.strftime("%Y").to_i,
      sign_in_month: Time.now.strftime("%B").to_i,
      sign_in_day: Time.now.strftime("%d").to_i,
      sign_in_hour: Time.now.strftime("%H").to_i,
      sign_in_minute: Time.now.strftime("%M").to_i,
      })
    if current_user.merchant? || current_user.admin?
      reports_path
    else
      session[:previous_url] || root_path
    end
  end
  
 
   def configure_permitted_parameters
     devise_parameter_sanitizer.for(:sign_up) << :username
   end
end