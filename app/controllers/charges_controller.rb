class ChargesController < ApplicationController
  before_filter :authenticate_user!
  def create
    #Track with Keen for Merchant & Admin
    #Time between purchases for customers in hours
    #Track product tags as well with Keen
    
    if !current_user.purchases.find_by(purchase_id: params[:purchase_id]).nil? && !current_user.purchases.find_by(purchase_id: params[:purchase_id]).refunded?
      flash[:error] = "You've Already Purchased This"
      redirect_to root_path
    else
      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      @price = params[:price].to_i

      if current_user.card?
        @card = @crypt.decrypt_and_verify(current_user.card_number)
        if User.find(Product.find_by(uuid: params[:uuid]).user_id).stripe_account_id
          
          @currency = User.find(Product.find_by(uuid: params[:uuid]).user_id).currency
          @stripe_account_id = @crypt.decrypt_and_verify(User.find(Product.find_by(uuid: params[:uuid]).user_id).stripe_account_id)
        end
        begin
          @token = Stripe::Token.create(
            card: {
              number: @card,
              exp_month: current_user.exp_month,
              exp_year: current_user.exp_year,
              country: current_user.address_country,
              cvc: current_user.cvc_number,
              name: current_user.legal_name,
              address_city: current_user.address_city,
              address_zip: current_user.address_zip,
              address_state: current_user.address_state,
              address_country: current_user.country_name,
            },
          )
        rescue Stripe::CardError => e
          redirect_to edit_user_registration_path
          flash[:error] = "#{e}"
          return
        rescue => e
          redirect_to edit_user_registration_path
          flash[:error] = "#{e}"
          return
        end

        if Product.find_by(uuid: params[:uuid]).user.role == 'admin'
          begin
            @charge = User.charge_for_admin(@price, @token.id)
            redirect_to root_path
            flash[:notice] = "Thanks for the purchase!"
            Purchase.create(uuid: params[:uuid], merchant_id: params[:merchant_id], stripe_charge_id: @charge.id,
                              title: params[:title], price: params[:price],
                              user_id: current_user.id, product_id: params[:product_id],
                              application_fee: 0, purchase_id: SecureRandom.uuid,
                              status: 'Paid',
              )
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
        else
          begin
            
            @charge = User.charge_n_process(@price, @token, @stripe_account_id, @currency, )
            
            redirect_to root_path
            flash[:notice] = "Thanks for the purchase!"
            Purchase.create(uuid: params[:uuid], merchant_id: params[:merchant_id], stripe_charge_id: @charge.id,
                              title: params[:title], price: params[:price],
                              user_id: current_user.id, product_id: params[:product_id],
                              application_fee: @charge.application_fee, purchase_id: SecureRandom.uuid,
                              status: 'Paid'
              )
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
      else
        redirect_to edit_user_registration_path
        flash[:error] = "You Are Missing Credit Card Details"
        return
      end
    end
  end
end
