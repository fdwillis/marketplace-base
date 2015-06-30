class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update_attributes(user_params)
      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      card = @crypt.encrypt_and_sign(current_user.card_number)
      ssn = @crypt.encrypt_and_sign(current_user.tax_id)
      account_number = @crypt.encrypt_and_sign(current_user.account_number)


      current_user.update_attributes(card_number: card, account_number: account_number, tax_id: ssn)
      current_user.save!
      flash[:notice] = "User information updated"
      redirect_to edit_user_registration_path
    else
      flash[:error] = "Invalid user information"
      redirect_to edit_user_registration_path
    end
  end

private
  def user_params
     params.require(:user).permit(:stripe_recipient_id, :name, :username, :legal_name, :card_number, :exp_month, :exp_year, :cvc_number, :tax_id, :account_number, :routing_number)
  end
end