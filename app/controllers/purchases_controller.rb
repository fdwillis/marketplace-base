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
    @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

    @order = Order.find(params[:order])

    @merchant = User.find(params[:merchant_id])
    
    @price = (@order.total_price * 100).to_i

    if current_user.card?
      @card = @crypt.decrypt_and_verify(current_user.card_number)
      @shipping_name = @order.shipping_option
      @ship_to = @order.ship_to
      
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

      if @merchant.role == 'admin'
        begin
          @charge = User.charge_for_admin(current_user, @price, @token.id)
          @order.update_attributes(stripe_charge_id: @charge.id, purchase_id: SecureRandom.uuid,
                                   paid: true, application_fee: @charge.application_fee)
                              
          redirect_to orders_path
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
          @order.order_items.each do |oi|
            @product = Product.find_by(uuid: oi.uuid)
            @product.update_attributes(quantity: @product.quantity - oi.quantity.to_i)
          end

          @charge = User.charge_n_process(@merchant.merchant_secret_key, current_user, @price, @token, @merchant_account_id, @currency)

          @order.update_attributes(stripe_charge_id: @charge.id, purchase_id: SecureRandom.uuid,
                                   paid: true, application_fee: @charge.application_fee)

          Stripe.api_key = Rails.configuration.stripe[:secret_key]

          @order.update_attributes(paid: true, status: "Paid")

          redirect_to orders_path
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
      redirect_to edit_user_registration_path
      flash[:error] = "You Are Missing Credit Card Details Or Shipping Information"
      return
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
