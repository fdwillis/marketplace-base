class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update_attributes(user_params)

      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

      if params[:user][:tax_id]
        ssn = @crypt.encrypt_and_sign(current_user.tax_id)
        current_user.update_attributes(tax_id: ssn)
      end

      if params[:user][:account_number]
        account_number = @crypt.encrypt_and_sign(current_user.account_number)
        current_user.update_attributes(account_number: account_number)
      end

      if params[:user][:card_number]
        card_number = @crypt.encrypt_and_sign(current_user.card_number)
        current_user.update_attributes(card_number: card_number)
      end

      if !current_user.stripe_id? && current_user.card?

        @card = @crypt.decrypt_and_verify(current_user.card_number)

        customer = Stripe::Customer.create(
          email: current_user.email,
          source: {
            object: 'card',
            number: @card,
            exp_month: current_user.exp_month,
            exp_year: current_user.exp_year,
            cvc: current_user.cvc_number,
          },
        )
      end

      flash[:notice] = "User information updated"
      redirect_to edit_user_registration_path
    else
      flash[:error] = "Isses: #{current_user.errors.full_messages.to_sentence.titleize}"
      redirect_to edit_user_registration_path
    end
  end

private
  def user_params
     params.require(:user).permit(:stripe_recipient_id, :name, :username, :legal_name, :card_number, :exp_month, :exp_year, :cvc_number, :tax_id, :account_number, :routing_number)
  end
end