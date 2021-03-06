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
            @charge = User.charge_n_process(@merchant.merchant_secret_key, current_user, @price, @token.id, @merchant_account_id)
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


      if params[:uuid]
        @fund = FundraisingGoal.find_by(uuid: params[:uuid])
        if params[:donate][:donation_type] 
          if params[:donate][:donation_type] == "One Time"
            if params[:donate][:donation].to_i >= 1
              begin
                if @merchant.role == 'admin'
                  @charge = User.charge_for_admin(current_user, @price, @token.id)
                  @donation = current_user.donations.create(donation_type: 'one-time', organization: @fund.user.username, amount: @price, uuid: SecureRandom.uuid, fundraising_goal_id: @fund.id)
                else
                  @charge = User.charge_n_process(@merchant.merchant_secret_key, current_user, @price, @token.id, @merchant_account_id)
                  Stripe.api_key = Rails.configuration.stripe[:secret_key]
                  @donation = current_user.donations.create(application_fee: ((Stripe::ApplicationFee.retrieve(@charge.application_fee).amount) / 100).to_f , donation_type: 'one-time', organization: @fund.user.username, amount: @price, uuid: SecureRandom.uuid, fundraising_goal_id: @fund.id)
                end
                
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
              return
            end
            Donation.donations_to_keen(@donation, request.remote_ip, request.location.data, 'web', false)
          else
            @donation_plan = DonationPlan.find_by(uuid: params[:donate][:donation_type])
            begin
              if @merchant.role == 'admin'
                @subscription = User.subscribe_to_admin(current_user, @token.id, @donation_plan.uuid)
                @donation = current_user.donations.create(stripe_plan_name: @subscription.plan.name, stripe_subscription_id: @donation_plan.uuid ,active: true, donation_type: 'subscription', subscription_id: @subscription.id ,organization: @fund.user.username, amount: @subscription.plan.amount, uuid: SecureRandom.uuid, fundraising_goal_id: @fund.id, fundraiser_stripe_account_id: @merchant.merchant_secret_key)
              else
                @subscription = User.subscribe_to_fundraiser(@merchant.merchant_secret_key, current_user, @token.id, @merchant_account_id, @donation_plan.uuid)
                Stripe.api_key = Rails.configuration.stripe[:secret_key]
                @donation = current_user.donations.create(application_fee: (@subscription.plan.amount * (@subscription.application_fee_percent / 100 ) / 100 ) , stripe_plan_name: @subscription.plan.name, stripe_subscription_id: @donation_plan.uuid ,active: true, donation_type: 'subscription', subscription_id: @subscription.id ,organization: @fund.user.username, amount: @subscription.plan.amount, uuid: SecureRandom.uuid, fundraising_goal_id: @fund.id, fundraiser_stripe_account_id: @merchant.merchant_secret_key)
              end
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
          redirect_to fundraising_goal_path(id: @fund.slug)
          flash[:error] = "Please Specify A Donation Type"
          return
        end
        @fund.increment!(:backers, by = 1)
      else
        if params[:donate][:donation_type] != "One Time"
          @donation_plan = DonationPlan.find_by(uuid: params[:donate][:donation_type])
          begin
            if @merchant.role == 'admin'
              @subscription = User.subscribe_to_admin(current_user, @token.id, @donation_plan.uuid)
              @donation = current_user.donations.create(stripe_plan_name: @subscription.plan.name, stripe_subscription_id: @donation_plan.uuid ,active: true, donation_type: 'subscription', subscription_id: @subscription.id ,organization: @merchant.username, amount: @subscription.plan.amount, uuid: SecureRandom.uuid, fundraiser_stripe_account_id: @merchant.merchant_secret_key)
            else
              @subscription = User.subscribe_to_fundraiser(@merchant.merchant_secret_key, current_user, @token.id, @merchant_account_id, @donation_plan.uuid)
              Stripe.api_key = Rails.configuration.stripe[:secret_key]
              @donation = current_user.donations.create(application_fee: (@subscription.plan.amount * (@subscription.application_fee_percent / 100 ) / 100 ) , stripe_plan_name: @subscription.plan.name, stripe_subscription_id: @donation_plan.uuid ,active: true, donation_type: 'subscription', subscription_id: @subscription.id ,organization: @merchant.username, amount: @subscription.plan.amount, uuid: SecureRandom.uuid, fundraiser_stripe_account_id: @merchant.merchant_secret_key)
            end
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
          if @merchant.admin?
            @charge = User.charge_for_admin(current_user, @price, @token.id)
            @donation = current_user.donations.create(donation_type: 'one-time', organization: @merchant.username, amount: @price, uuid: SecureRandom.uuid)
          else
            @charge = User.charge_n_process(@merchant.merchant_secret_key, current_user, @price, @token.id, @merchant_account_id)
            Stripe.api_key = Rails.configuration.stripe[:secret_key]
            @donation = current_user.donations.create(application_fee: ((Stripe::ApplicationFee.retrieve(@charge.application_fee).amount) / 100).to_f , donation_type: 'one-time', organization: @merchant.username, amount: @price, uuid: SecureRandom.uuid)
          end
        end

        Donation.donations_to_keen(@donation, request.remote_ip, request.location.data, 'web', true)  
      end
      
      if current_user.notifications == true
        @merchant.email_lists.find_or_create_by(email: current_user.email )
      end
      Stripe.api_key = Rails.configuration.stripe[:secret_key]
      redirect_to request.referrer
      flash[:notice] = "#{@merchant.username.capitalize} Thanks You For Your Donation!"
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
