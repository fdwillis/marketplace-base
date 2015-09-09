class SubscribeController < ApplicationController
before_filter :authenticate_user!

  def update
    #Track for admin
    # Create Multiple Records at once
      # Role.create(
      #   [
      #     { :role => 'merchant') },
      #     { :role => 'teams') }
      #   ]
      # )
    Bitly.use_api_version_3

    Bitly.configure do |config|
      config.api_version = 3
      config.access_token = ENV['BITLY_ACCESS_TOKEN']
    end

    @bitly_link = Bitly.client.shorten("https://marketplace-base.herokuapp.com/merchants/#{current_user.username}").short_url

    plan = Stripe::Plan.retrieve(params[:id])
    @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

    @card_number = @crypt.encrypt_and_sign(params[:user][:card_number])
    @exp_month = params[:user][:exp_month]
    @exp_year = params[:user][:exp_year]
    @cvc_number = params[:user][:cvc_number]
    @username = params[:user][:username]
    begin
      @token = Stripe::Token.create(
        card: {
          number: @crypt.decrypt_and_verify(@card_number),
          exp_month: @exp_month.to_i,
          exp_year: @exp_year.to_i,
          cvc: @cvc_number,
          address_line1: current_user.address,
          address_city: current_user.address_city,
          address_zip: current_user.address_zip,
          address_state: current_user.address_state,
          address_country: current_user.address_country,
        },
      )
    rescue Stripe::CardError => e
      flash[:error] = "#{e}"
      redirect_to edit_user_registration_path
      return
    rescue => e
      flash[:error] = "#{e}"
      redirect_to edit_user_registration_path
      return
    end
    if !current_user.stripe_plan_id.nil?  

      customer = Stripe::Customer.retrieve(current_user.marketplace_stripe_id)
      subscription = customer.subscriptions.retrieve(current_user.stripe_plan_id)
      
      subscription.plan = plan.id
      subscription.save

      current_user.update_attributes(stripe_plan_name: plan.name, bitly_link: @bitly_link )
      current_user.roles.find_or_create_by(title: 'donations')
      redirect_to root_path, notice: "You Updated Your Plan To: #{plan.name}"
      return
    elsif current_user.card?
      if !current_user.marketplace_stripe_id.nil?
        customer = Stripe::Customer.retrieve(current_user.marketplace_stripe_id)
        subscription = customer.subscriptions.create(plan: plan)

        if current_user.products.present?
          current_user.products.each do |p|
            p.update_attributes(active: true)
          end
        end

        current_user.update_attributes(stripe_plan_id: subscription.id , stripe_plan_name: plan.name, account_approved: false)
        current_user.roles.find_or_create_by(title: 'donations')

        flash[:notice] = "Welcome Back! You Joined The #{plan.name} Plan"
        redirect_to edit_user_registration_path
        return
      else
        begin

          subscription = User.subscribe_to_admin(current_user, @token.id, plan.id)

          User.new_paying_merchant(request.location.data, request.remote_ip, subscription.plan.amount, current_user)
          
          current_user.update_attributes(slug: @username = params[:user][:username], marketplace_stripe_id: subscription.customer, 
                                         username: @username = params[:user][:username], card_number: @card_number, exp_year: @exp_year, 
                                         exp_month: @exp_month, cvc_number: @cvc_number, stripe_plan_id: subscription.id,
                                         stripe_plan_name: subscription.plan.name, bitly_link: @bitly_link)
          current_user.roles.find_or_create_by(title: 'donations')

          flash[:notice] = "Happy To Have You! Submit Your Fundraising Application For Approval Below!"
          redirect_to edit_user_registration_path
          return
        rescue Stripe::CardError => e
          flash[:error] = "#{e}"
          redirect_to edit_user_registration_path
          return
        rescue => e
          flash[:error] = "#{e}"
        end
      end
    else
      flash[:error] = "Please Add All Payment & Shipping Info"
      redirect_to edit_user_registration_path
      return
    end
  end

  def destroy
    # merchant canceled
    customer = Stripe::Customer.retrieve(current_user.marketplace_stripe_id)
    customer.subscriptions.retrieve(current_user.stripe_plan_id).delete

    if current_user.products.present?
      current_user.products.each do |p|
        p.update_attributes(active: false)
      end
    end

    if current_user.fundraising_goals.present?
      current_user.fundraising_goals.each do |goal|
        goal.update_attributes(active: false)
      end
    end
    merchant_orders = Order.all.where(merchant_id: current_user.id)
    User.merchant_cancled(current_user, (merchant_orders.map(&:total_price).sum - merchant_orders.map(&:refund_amount).sum))

    current_user.update_attributes(role: 'buyer', stripe_plan_id: nil, stripe_plan_name: nil)
    redirect_to edit_user_registration_path
    flash[:error] = "You No Longer Are A Merchant"
  end
end