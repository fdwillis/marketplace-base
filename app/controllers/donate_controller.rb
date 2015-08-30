class DonateController < ApplicationController
  def donate
  end

  def create_user
  	crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
    phone_number = params[:create_user][:phone_number]
  	stripe_amount = params[:create_user][:stripe_amount].to_i
  	fundraiser = User.find_by(username: params[:create_user][:fundraiser_name])
    card_number = params[:create_user][:card_number]
    legal_name = params[:create_user][:legal_name]
    user_exists = User.find_by(support_phone: phone_number, legal_name: legal_name)
    email = params[:create_user][:email]
    cvc_number = params[:create_user][:cvc_number]
    exp_year = params[:create_user][:exp_year]
    exp_month = params[:create_user][:exp_month]

    if user_exists
      new_user = user_exists
    else
      if exp_year.to_i >= 2015 && exp_month.to_i >= 1
        if !User.all.map(&:email).include?(email)
          new_user = User.create!(currency: 'USD', support_phone: phone_number, email: email, password: params[:create_user][:password], legal_name: legal_name, exp_month: exp_month, exp_year: exp_year.to_i, cvc_number: cvc_number, card_number: crypt.encrypt_and_sign(card_number))
        else
          redirect_to request.referrer
          flash[:error] = "Email Has Been Taken"
          return
        end
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
        if params[:create_user][:donation_plan].present?
          User.subscribe_to_admin(new_user, a_token.id, DonationPlan.find_by(uuid: params[:create_user][:donation_plan]).uuid )
        else
      		User.charge_for_admin(new_user, stripe_amount, a_token.id )
        end
    	else
        
        if params[:create_user][:donation_plan].present?
          User.subscribe_to_fundraiser(fundraiser.merchant_secret_key, new_user, a_token.id, crypt.decrypt_and_verify(fundraiser.stripe_account_id), DonationPlan.find_by(uuid: params[:create_user][:donation_plan]).uuid  )
        else
      	 User.decrypt_and_verify(fundraiser.merchant_secret_key)
      	 User.charge_n_process(fundraiser.merchant_secret_key, new_user, stripe_amount, a_token.id, crypt.decrypt_and_verify(fundraiser.stripe_account_id))
        end
    	end

    rescue Stripe::CardError => e
      if params[:create_user][:donation_plan].present?
        redirect_to request.referrer
      else
        redirect_to donate_path(card_number: card_number, cvc_number: cvc_number, amount: stripe_amount, fundraiser_name: fundraiser, phone_number: phone_number, legal_name: legal_name, email: email, exp_month: exp_month, exp_year: exp_year)
      end

      new_user.destroy!
      flash[:error] = "#{e}"
      return
    rescue => e
      if params[:create_user][:donation_plan].present?
        redirect_to request.referrer
      else
        redirect_to donate_path(card_number: card_number, cvc_number: cvc_number, amount: stripe_amount, fundraiser_name: fundraiser, phone_number: phone_number, legal_name: legal_name, email: email, exp_month: exp_month, exp_year: exp_year)
      end

      new_user.destroy!
      flash[:error] = "#{e}"
      return
    end

  	redirect_to donate_path
    # Twilio text telling user they can text from now on and will be charged automatically
  	flash[:notice] = "Thanks For The Donation"
  end
end
