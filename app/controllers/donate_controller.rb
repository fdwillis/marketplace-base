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
      if exp_year.to_i >= Time.now.strftime('%Y').to_i && exp_month.to_i >= 1
        if !User.all.map(&:email).include?(email)
          new_user = User.create!(currency: 'USD', support_phone: phone_number, email: email, password: params[:create_user][:password], legal_name: legal_name, exp_month: exp_month, exp_year: exp_year.to_i, cvc_number: cvc_number, card_number: crypt.encrypt_and_sign(card_number))
        else
          redirect_to request.referrer
          flash[:error] = "Email Has Been Taken"
          return
        end
      else
        redirect_to request.referrer
        flash[:error] = "Expiration Year Or Month Was Invalid. Please Try Again"
        return
      end
    end

    begin
      token = User.new_token(new_user, card_number)

      customer = User.new_customer(token.id, new_user)

      a_token = User.new_token(new_user, card_number)

      if fundraiser.role == 'admin'
        if params[:create_user][:donation_plan].present?
          donation_plan = DonationPlan.find_by(uuid: params[:create_user][:donation_plan]).uuid
          subscription = User.subscribe_to_admin(new_user, a_token.id, donation_plan )
          @donation = new_user.donations.create!(stripe_plan_name: subscription.plan.name, stripe_subscription_id: donation_plan ,active: true, donation_type: 'subscription', subscription_id: subscription.id ,organization: fundraiser.username, amount: subscription.plan.amount, uuid: SecureRandom.uuid)
        else
          User.charge_for_admin(new_user, stripe_amount, a_token.id )
          @donation = new_user.donations.create!(donation_type: 'one-time', organization: fundraiser.username, amount: (stripe_amount / 100).to_f, uuid: SecureRandom.uuid)
        end
      else
        
        if params[:create_user][:donation_plan].present?
          donation_plan = DonationPlan.find_by(uuid: params[:create_user][:donation_plan]).uuid
          subscription = User.subscribe_to_fundraiser(fundraiser.merchant_secret_key, new_user, a_token.id, crypt.decrypt_and_verify(fundraiser.stripe_account_id), donation_plan  )
          @donation = new_user.donations.create!(application_fee: (subscription.plan.amount * (subscription.application_fee_percent / 100 ) / 100 ) , stripe_plan_name: subscription.plan.name, stripe_subscription_id: donation_plan ,active: true, donation_type: 'subscription', subscription_id: subscription.id, organization: fundraiser.username, amount: subscription.plan.amount, uuid: SecureRandom.uuid, fundraiser_stripe_account_id: fundraiser.merchant_secret_key)
        else
      	  User.decrypt_and_verify(fundraiser.merchant_secret_key)
      	  charge = User.charge_n_process(fundraiser.merchant_secret_key, new_user, stripe_amount, a_token.id, crypt.decrypt_and_verify(fundraiser.stripe_account_id))
          Stripe.api_key = Rails.configuration.stripe[:secret_key]
          @donation = new_user.donations.create!(application_fee: ((Stripe::ApplicationFee.retrieve(charge.application_fee).amount) / 100).to_f , donation_type: 'one-time', organization: fundraiser.username, amount: (stripe_amount / 100).to_f, uuid: SecureRandom.uuid)
        end
      end
      
      Donation.donations_to_keen(@donation, request.remote_ip, request.location.data, 'text')
      fundraiser.text_lists.find_or_create_by(phone_number: phone_number)
      Stripe.api_key = Rails.configuration.stripe[:secret_key]
      # Twilio text telling user they can text from now on and will be charged automatically
      redirect_to donate_path
      flash[:notice] = "Thanks For The Donation"
      return
    rescue Stripe::CardError => e
      if params[:create_user][:donation_plan].present?
        redirect_to request.referrer
      else
        redirect_to request.referrer
      end
      new_user.destroy!
      flash[:error] = "#{e}"
      return
    rescue => e
      if params[:create_user][:donation_plan].present?
        redirect_to request.referrer
      else
        redirect_to request.referrer
      end
      new_user.destroy!
      flash[:error] = "#{e}"
      return
    end
  end
end
