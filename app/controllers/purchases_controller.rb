class PurchasesController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    #Track with Keen for Merchant & Admin
    #Time between purchases for customers in hours
    #Track product tags as well with Keen
    #Grab country of the card by switching to the merchant and using Stripe::Charge.retrieve(charge_id).source.country
    @merchant = User.find(params[:merchant_id])
    @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
    
    if @merchant.stripe_account_id
      @currency = @merchant.currency
      @merchant_account_id = @crypt.decrypt_and_verify(@merchant.stripe_account_id)
    end

    if params[:order]

      @order = Order.find(params[:order])

      
      @price = (@order.total_price * 100).to_i

      if current_user.card?
        @card = @crypt.decrypt_and_verify(current_user.card_number)
        @shipping_name = @order.shipping_option
        @ship_to = @order.ship_to
        
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

        begin
          if @merchant.role == 'admin'
            @charge = User.charge_for_admin(current_user, @price, @token.id)
          else
            @charge = User.charge_n_process(@merchant.merchant_secret_key, current_user, @price, @token.id, @merchant_account_id, @currency)
            Stripe.api_key = Rails.configuration.stripe[:secret_key]
          end

          @order.update_attributes(stripe_charge_id: @charge.id, purchase_id: SecureRandom.uuid,
                                   paid: true, application_fee: @charge.application_fee, status: "Paid")

          @order.order_items.each do |oi|
            @product = Product.find_by(uuid: oi.product_uuid)
            @product.update_attributes(quantity: @product.quantity - oi.quantity.to_i)
          end

          Order.orders_to_keen(@order, request.remote_ip, request.location.data)
          
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
        redirect_to edit_user_registration_path
        flash[:error] = "You Are Missing Credit Card Details Or Shipping Information"
        return
      end
    else
      @fund = FundraisingGoal.find_by(uuid: params[:uuid])
      @price = params[:donate][:donation].to_i * 100
      @card = @crypt.decrypt_and_verify(current_user.card_number)

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

      if params[:donate][:donation_type] 
        if params[:donate][:donation_type] == "One Time"
          if params[:donate][:donation].to_i > 0
            begin
              if @merchant.role == 'admin'
                @charge = User.charge_for_admin(current_user, @price, @token.id)
              else
                @charge = User.charge_n_process(@merchant.merchant_secret_key, current_user, @price, @token, @merchant_account_id, @currency)
                Stripe.api_key = Rails.configuration.stripe[:secret_key]
              end

              @donation = current_user.donations.create(donation_type: 'one-time', organization: @fund.user.username, amount: @price, uuid: SecureRandom.uuid, fundraising_goal_id: @fund.id)
              @fund.increment!(:backers, by = 1)

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
            redirect_to fundraising_goal_path(id: @fund.slug)
            flash[:error] = "Please Specify A Valid Donation Amount"
          end
        else
          @donation_plan = DonationPlan.find_by(uuid: params[:donate][:donation_type])
          begin
            if @merchant.role == 'admin'
              @subscription = User.subscribe_to_admin(current_user, @token.id, @donation_plan)
            else
              @subscription = User.subscribe_to_fundraiser(@merchant.merchant_secret_key, current_user, @token.id, @merchant_account_id, @donation_plan)
              Stripe.api_key = Rails.configuration.stripe[:secret_key]
            end

            @donation = current_user.donations.create(application_fee: (@subscription.plan.amount * (@subscription.application_fee_percent / 100 ) / 100 ) , stripe_plan_name: @subscription.plan.name, stripe_subscription_id: @donation_plan.uuid ,active: true, donation_type: 'subscription', subscription_id: @subscription.id ,organization: @fund.user.username, amount: @subscription.plan.amount, uuid: SecureRandom.uuid, fundraising_goal_id: @fund.id, fundraiser_stripe_account_id: @merchant.merchant_secret_key)
            
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

        Donation.donations_to_keen(@donation, request.remote_ip, request.location.data)

        @fund.increment!(:backers, by = 1)
        redirect_to fundraising_goals_path
        flash[:notice] = "Thanks for the donation!"
        return

      else
        redirect_to fundraising_goal_path(id: @fund.slug)
        flash[:error] = "Please Specify A Donation Type"
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
