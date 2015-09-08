class UsersController < ApplicationController
  before_filter :authenticate_user!

  def update
    if current_user.update_attributes(user_params)

      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

      if params[:user][:username]
        current_user.update_attributes(username: params[:user][:username].gsub(" ", "_"))
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
                    
          @token = User.new_token(current_user, params[:user][:card_number])
          
          @charge = Stripe::Charge.create(
            :amount => 50,
            :currency => "usd",
            :source => @token.id,
            :description => "Validation Charge"
          )
          
          ch = Stripe::Charge.retrieve(@charge.id)
          refund = ch.refunds.create
          flash[:notice] = "Start Your Application!"
          if !current_user.roles.map(&:title).include?('buyer')
            redirect_to plans_path
          else
            redirect_to request.referrer
          end
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
      
      if !current_user.stripe_account_id? && current_user.account_ready?
        begin 

          merchant = User.create_merchant(current_user, request.remote_ip, browser.user_agent )
          
          @stripe_account_id = @crypt.encrypt_and_sign(merchant.id)
          @merchant_secret_key = @crypt.encrypt_and_sign(merchant.keys.secret)
          @merchant_publishable_key = @crypt.encrypt_and_sign(merchant.keys.publishable)

          current_user.update_attributes(merchant_approved: false, stripe_account_id:  @stripe_account_id , merchant_secret_key: @merchant_secret_key, merchant_publishable_key: @merchant_publishable_key, bitly_link: @bitly_link )
          flash[:notice] = "User Information Updated"
          redirect_to request.referrer
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
    redirect_to request.referrer
    return
  end

private
  def user_params
     params.require(:user).permit(:logo, :shipping_address, :return_policy, :address, :currency, :address_country, 
                                  :address_state, :address_zip, :address_city, :stripe_account_type, :dob_day, 
                                  :dob_month, :dob_year, :first_name, :last_name, :statement_descriptor, :support_url, 
                                  :merchant_approved, :support_phone, :support_email, :business_url, :merchant_id, :business_name,
                                  :stripe_recipient_id, :name, :username, :legal_name, :card_number, :exp_month, 
                                  :exp_year, :cvc_number, :tax_id, :account_number, :routing_number, :country_name, 
                                  :tax_rate,:bank_currency, shipping_addresses_attributes: [:id, :street, :city, :state, :region, :zip, :_destroy],
                                  stripe_customer_ids_attributes: [:business_name, :customer_id, :customer_card, :_destroy],
                                  orders_attributes: [:id, :status, :ship_to, :customer_name, :tracking_number, :shipping_option, :total_price, :user_id, :_destroy], 
                                  donation_plans_attributes: [:id, :amount, :interval, :name, :currency, :uuid, :_destroy],
                                  team_members_attributes: [:id, :name, :percent, :stripe_bank_id, :uuid, :routing_number, :country, :account_number, :_destroy])
  end
end