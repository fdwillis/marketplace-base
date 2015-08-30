class DonateController < ApplicationController
  def donate
  end

  def create_user
    
  	crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
    phone_number = params[:create_user][:phone_number]
  	stripe_amount = params[:create_user][:stripe_amount].to_i
  	fundraiser = User.find_by(username: params[:create_user][:fundraiser_name])
    user_exists = User.find_by(support_phone: phone_number)
    card_number = params[:create_user][:card_number]
    legal_name = params[:create_user][:legal_name]
    email = params[:create_user][:email]
    cvc_number = params[:create_user][:cvc_number]
    exp_year = params[:create_user][:exp_year]
    exp_month = params[:create_user][:exp_month]

    if user_exists
      new_user = user_exists
    else
      if exp_year.to_i >= 2015 && exp_month.to_i >= 1
        new_user = User.create!(currency: 'USD', support_phone: phone_number, email: email, password: params[:create_user][:password], legal_name: legal_name, exp_month: exp_month, exp_year: exp_year.to_i, cvc_number: cvc_number, card_number: crypt.encrypt_and_sign(card_number))
      else
        redirect_to donate_path(card_number: card_number, cvc_number: cvc_number, amount: stripe_amount, fundraiser_name: fundraiser, phone_number: phone_number, legal_name: legal_name, email: email, exp_month: exp_month, exp_year: exp_year)
        flash[:error] = "Expiration Year Or Month Is Invalid"
        return
      end
    end

    begin
      token = User.new_token(new_user, card_number)

      customer = User.new_customer(token.id, new_user)

    	a_token = User.new_token(new_user, card_number)

    	if fundraiser.role == 'admin'
    		User.charge_for_admin(new_user, stripe_amount, a_token.id )
    	else
    	 User.decrypt_and_verify(fundraiser.merchant_secret_key)
    	 User.charge_n_process(fundraiser.merchant_secret_key, new_user, stripe_amount, a_token.id, crypt.decrypt_and_verify(fundraiser.stripe_account_id))
    	end

    rescue Stripe::CardError => e
      redirect_to donate_path(card_number: card_number, cvc_number: cvc_number, amount: stripe_amount, fundraiser_name: fundraiser, phone_number: phone_number, legal_name: legal_name, email: email, exp_month: exp_month, exp_year: exp_year)
      new_user.destroy!
      flash[:error] = "#{e}"
      return
    rescue => e
      redirect_to donate_path(card_number: card_number, cvc_number: cvc_number, amount: stripe_amount, fundraiser_name: fundraiser, phone_number: phone_number, legal_name: legal_name, email: email, exp_month: exp_month, exp_year: exp_year)
      new_user.destroy!
      flash[:error] = "#{e}"
      return
    end

  	redirect_to donate_path
    # Twilio text telling user they can text from now on and will be charged automatically
  	flash[:notice] = "Thanks For The Donation"
  end
end
