class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update_attributes(user_params)
      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

      if params[:user][:donation_plans_attributes]

        donation_plans = params[:user][:donation_plans_attributes]
        donation_plans.each do |plan|
          @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
          Stripe.api_key = @crypt.decrypt_and_verify(current_user.merchant_secret_key)

          Stripe::Plan.create(
            :amount => ((plan[1]['amount'].to_f) * 100).to_i,
            :interval => 'month',
            :name => plan[1]['name'],
            :currency => 'usd',
            :id => plan[1]['uuid']
          )
        end

        Stripe.api_key = Rails.configuration.stripe[:secret_key]
      end


      if params[:stripe_account_type]
        current_user.update_attributes(stripe_account_type: params[:stripe_account_type])
      end
      if params[:user][:tax_id]
        ssn = @crypt.encrypt_and_sign(current_user.tax_id)
        current_user.update_attributes(tax_id: ssn)
      end

      if params[:user][:account_number]
        account_number = @crypt.encrypt_and_sign(current_user.account_number)
        current_user.update_attributes(account_number: account_number)
      end

      if !params[:user][:card_number].nil?
        
        begin
          card_number = @crypt.encrypt_and_sign(params[:user][:card_number])
          current_user.update_attributes(card_number: card_number)

          @token = Stripe::Token.create(
            :card => {
              :number => @crypt.decrypt_and_verify(current_user.card_number),
              :exp_month => params[:user][:exp_month].to_i,
              :exp_year => params[:user][:exp_year].to_i,
              :cvc => params[:user][:cvc_number].to_i
            },
          )
          
          @charge = Stripe::Charge.create(
            :amount => 50,
            :currency => "usd",
            :source => @token.id,
            :description => "Validation Charge"
          )
          
          ch = Stripe::Charge.retrieve(@charge.id)
          refund = ch.refunds.create
          flash[:notice] = "User Information Updated"
          redirect_to edit_user_registration_path
          return
        rescue Stripe::CardError => e
          redirect_to edit_user_registration_path
          flash[:error] = "#{e}"
          return
        rescue => e
          redirect_to edit_user_registration_path
          flash[:error] = "#{e}"
          return
        end
      end
      
      if !current_user.stripe_account_id? && current_user.merchant_ready? && !current_user.merchant_id?        
        begin 
          #Merchant creation from sign of signup, to merchant creation
          merchant = Stripe::Account.create(
              managed: true,
              country: current_user.address_country,
              email: current_user.email,
              business_url: current_user.business_url,
              business_name: current_user.business_name,
              support_url: current_user.support_url,
              support_phone: current_user.support_phone,
              support_email: current_user.support_email,
              debit_negative_balances: true,
              external_account: {
                object: 'bank_account',
                country: current_user.address_country,
                currency: current_user.currency,
                routing_number: current_user.routing_number,
                account_number: @crypt.decrypt_and_verify(current_user.account_number),
              },
              tos_acceptance: {
                ip: request.remote_ip,
                date: Time.now.to_i,
                user_agent: browser.full_version,
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
                address: {
                  line1: current_user.address,
                  city: current_user.address_city,
                  state: current_user.address_state,
                  postal_code: current_user.address_zip,
                  country: current_user.address_country,
                }
              },
              decline_charge_on: {
                cvc_failure: true,
              },
              transfer_schedule:{
                interval: 'manual',
              },
          )
          @stripe_account_id = @crypt.encrypt_and_sign(merchant.id)
          @merchant_secret_key = @crypt.encrypt_and_sign(merchant.keys.secret)
          @merchant_publishable_key = @crypt.encrypt_and_sign(merchant.keys.publishable)
          Bitly.use_api_version_3
          Bitly.configure do |config|
            config.api_version = 3
            config.access_token = ENV["BITLY_ACCESS_TOKEN"]
          end
          
          @bitly_link = Bitly.client.shorten("https://marketplace-base.herokuapp.com/merchants/#{current_user.username}").short_url

          current_user.update_attributes(stripe_account_id:  @stripe_account_id , merchant_secret_key: @merchant_secret_key, merchant_publishable_key: @merchant_publishable_key, bitly_link: @bitly_link )
          flash[:notice] = "User Information Updated"
          redirect_to edit_user_registration_path
          return
        rescue Stripe::CardError => e
          flash[:error] = "#{e}"
          redirect_to edit_user_registration_path
          return
        rescue => e
          flash[:error] = "#{e}"
          redirect_to edit_user_registration_path
          return
        end
      end
    else
      flash[:error] = "Isses: #{current_user.errors.full_messages.to_sentence.titleize}"
      redirect_to edit_user_registration_path
      return
    end
    flash[:notice] = "User Information Updated"
    redirect_to edit_user_registration_path
    return
  end

private
  def user_params
     params.require(:user).permit(:shipping_address, :return_policy, :address, :currency, :address_country, 
                                  :address_state, :address_zip, :address_city, :stripe_account_type, :dob_day, 
                                  :dob_month, :dob_year, :first_name, :last_name, :statement_descriptor, :support_url, 
                                  :merchant_approved, :support_phone, :support_email, :business_url, :merchant_id, :business_name,
                                  :stripe_recipient_id, :name, :username, :legal_name, :card_number, :exp_month, 
                                  :exp_year, :cvc_number, :tax_id, :account_number, :routing_number, :country_name, 
                                  :tax_rate,:bank_currency, shipping_addresses_attributes: [:id, :street, :city, :state, :region, :zip, :_destroy],
                                  stripe_customer_ids_attributes: [:business_name, :customer_id, :customer_card, :_destroy],
                                  orders_attributes: [:id, :status, :ship_to, :customer_name, :tracking_number, :shipping_option, :total_price, :user_id, :_destroy], 
                                  donation_plans_attributes: [:id, :amount, :interval, :name, :currency, :uuid, :_destroy])
  end
end