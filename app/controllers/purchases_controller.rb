class PurchasesController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @purchases = Purchase.all.where(user_id: current_user.id).order("refunded ASC")
    @orders = Purchase.all.where(merchant_id: current_user.id).order("created_at DESC")
  end
  def create
    #Track with Keen for Merchant & Admin
    #Time between purchases for customers in hours
    #Track product tags as well with Keen
    #Grab country of the card by switching to the merchant and using Stripe::Charge.retrieve(charge_id).source.country
    if !current_user.purchases.find_by(purchase_id: params[:purchase_id]).nil? && !current_user.purchases.find_by(purchase_id: params[:purchase_id]).refunded?
      redirect_to root_path
      flash[:error] = "You've Already Purchased This"
      return
    else
      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      @product = Product.find_by(uuid: params[:uuid])
      @merchant = User.find(@product.user_id)

      @product_q = @product.quantity
      @quantity = params[:quantity].to_i
      @new_q = @product_q - @quantity
      
      @price = ((params[:price].to_i * @quantity) + params[:shipping_option].to_i)

      if current_user.card?
        @card = @crypt.decrypt_and_verify(current_user.card_number)
        @shipping_name = @product.shipping_options.find_by(price: (params[:shipping_option].to_f/100)).title
        @ship_to = params[:ship_to]
        debugger
        if @merchant.stripe_account_id
          @currency = @merchant.currency
          @merchant_account_id = @crypt.decrypt_and_verify(@merchant.stripe_account_id)
        end
        begin
          @token = User.new_token(current_user, @card)
        rescue Stripe::CardError => e
          redirect_to edit_user_registration_path
          flash[:error] = "#{e}"
          return
        rescue => e
          redirect_to edit_user_registration_path
          flash[:error] = "#{e}"
          return
        end

        if @quantity > 0
          if @quantity  
            if params[:refund_agreement]
              if params[:shipping_option]
                if @product.user.role == 'admin'
                  begin
                    @charge = User.charge_for_admin(current_user, @price, @token.id)
                    
                    Purchase.new_product(params[:uuid], params[:merchant_id], @charge.id,
                                         params[:title], @price, current_user.id, params[:product_id],
                                         @charge.application_fee, SecureRandom.uuid,
                                         "#{@charge.status}", @shipping_name, @ship_to, @quantity,
                      )

                    Purchase.update_quantity(@new_q, @product)
                    
                    redirect_to root_path
                    flash[:notice] = "Thanks for the purchase!"
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
                    @charge = User.charge_n_process(@merchant.merchant_secret_key, current_user, @price, @token, @merchant_account_id, @currency)
                    
                    Purchase.new_product(params[:uuid], params[:merchant_id], @charge.id,
                                         params[:title], @price, current_user.id, params[:product_id],
                                         @charge.application_fee, SecureRandom.uuid,
                                         "#{@charge.status}", @shipping_name, @ship_to, @quantity,
                      )

                    Stripe.api_key = Rails.configuration.stripe[:secret_key]

                    Purchase.update_quantity(@new_q, @product)

                    redirect_to root_path
                    flash[:notice] = "Thanks for the purchase!"
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
                redirect_to product_path(params[:product_id])
                flash[:error] = "Please Choose A Shipping Option"
                return
              end
            else
              redirect_to product_path(params[:product_id])
              flash[:error] = "Please Agree To The Sellers Return Policy"
              return
            end
          else
            redirect_to product_path(params[:product_id])
            flash[:error] = "Please Choose Your Desired Quantity"
            return
          end
        else
          redirect_to product_path(params[:product_id])
          flash[:error] = "Please Choose Your Quantity"
          return
        end
      else
        redirect_to edit_user_registration_path
        flash[:error] = "You Are Missing Credit Card Details Or Shipping Information"
        return
      end
    end
  end

  def update
    AfterShip.api_key = ENV['AFTERSHIP_KEY']
    @tracking_number = params[:tracking_number]
    @purchase = Purchase.find_by(uuid: params[:uuid])
    @s = AfterShip::V4::Tracking.create( @tracking_number, {:emails => ["#{@purchase.user.email}"]})
    @purchase.update_attributes(tracking_number: @tracking_number, carrier: @s['data']['tracking']['slug'])
    redirect_to purchases_path
  end
private
  # Never trust parameters from the scary internet, only allow the white list through.
  def purchase_params
    params.require(:purchase).permit(:carrier, :tracking_number, :ship_to, :shipping_option, :quantity, :description, :title, :price, :uuid, :user_id, :product_id, :refunded, :stripe_charge_id, :merchant_id, :application_fee, :purchase_id, :status)
  end
end
