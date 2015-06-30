class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update_attributes(user_params)
      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      data = crypt.encrypt_and_sign(current_user.card_number)
      current_user.update_attributes(card_number: data)
      current_user.save!
      flash[:notice] = "User information updated"
      redirect_to edit_user_registration_path
      debugger
    else
      flash[:error] = "Invalid user information"
      redirect_to edit_user_registration_path
    end
  end

private
  def user_params
     params.require(:user).permit(:name, :username, :legal_name, :card_number, :exp_month, :exp_year, :cvc_number)
  end
end