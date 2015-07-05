class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update_attributes(user_params)
      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

      if params[:stripe_account_type] || params[:user][:tax_id] || params[:user][:account_number] || params[:user][:card_number] || params[:user][:routing_number]

        current_user.update_attributes(stripe_account_type: params[:stripe_account_type])

        ssn = @crypt.encrypt_and_sign(current_user.tax_id)
        current_user.update_attributes(tax_id: ssn)

        account_number = @crypt.encrypt_and_sign(params[:user][:account_number])
        current_user.update_attributes(account_number: account_number)
        length = params[:user][:account_number].length
        current_user.update(merchant_last_4: params[:user][:account_number].slice((length - 4)..length))

        card_number = @crypt.encrypt_and_sign(current_user.card_number)
        current_user.update_attributes(card_number: card_number)
      end
      
      if !current_user.stripe_account_id? && current_user.merchant_ready?

        # Track with Keen
        #make account instead of customer
        #add address to merchants
        merchant = Stripe::Account.create(
            :managed => true,
            :country => 'US',
            :email => current_user.email,
            business_url: current_user.business_url,
            business_name: current_user.business_name,
            support_url: current_user.support_url,
            support_phone: current_user.support_phone,
            support_email: current_user.support_email,
            debit_negative_balances: true,
            external_account: {
              object: 'bank_account',
              country: 'US',
              currency: 'usd',
              routing_number: current_user.routing_number,
              account_number: @crypt.decrypt_and_verify(current_user.account_number),
            },
            tos_acceptance: {
              ip: request.remote_ip,
              date: Time.now.to_i,
            },
            legal_entity: {
              type: current_user.stripe_account_type,
              business_name: current_user.business_name,
              first_name: current_user.first_name,
              last_name: current_user.last_name,
              dob: {
                day: current_user.dob_day,
                month: current_user.dob_month,
                year: current_user.dob_year,
                },
              },
        )
        @stripe_account_id = @crypt.encrypt_and_sign(merchant.id)
        @merchant_secret_key = @crypt.encrypt_and_sign(merchant.keys.secret)
        @merchant_publishable_key = @crypt.encrypt_and_sign(merchant.keys.publishable)

        current_user.update_attributes(stripe_account_id:  @stripe_account_id , merchant_secret_key: @merchant_secret_key, merchant_publishable_key: @merchant_publishable_key )
      end

      flash[:notice] = "User information updated"
      redirect_to edit_user_registration_path
    else
      flash[:error] = "Isses: #{current_user.errors.full_messages.to_sentence.titleize}"
      redirect_to edit_user_registration_path
    end
  end
  def merchant_bank
    debugger
    if current_user.merchant_changed?
      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      Stripe.api_key = @crypt.decrypt_and_verify(current_user.merchant_secret_key)
      merchant_account = Stripe::Account.retrieve(@crypt.decrypt_and_verify(current_user.stripe_account_id))

      bank_token = Stripe::Token.create(
          bank_account: {
          country: "US",
          routing_number: current_user.routing_number,
          account_number: current_user.account_number,
        },
      )
       merchant_account.external_accounts.create({external_account: bank_token.id})
    end

    Stripe.api_key = Rails.configuration.stripe[:secret_key]
  end
  def changed
    debugger
    current_user.merchant_changed?
  end
private
  def user_params
     params.require(:user).permit(:merchant_last_4, :stripe_account_type, :dob_day, :dob_month, :dob_year, :first_name, :last_name, :statement_descriptor, :support_url, :support_phone, :support_email, :business_url, :merchant_id, :business_name, :stripe_recipient_id, :name, :username, :legal_name, :card_number, :exp_month, :exp_year, :cvc_number, :tax_id, :account_number, :routing_number)
  end
end