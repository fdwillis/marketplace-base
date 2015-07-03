class SubscribeController < ApplicationController
before_filter :authenticate_user!

  def update
    plan = Stripe::Plan.retrieve(params[:id])

    if current_user.stripe_plan_name?  

      customer = Stripe::Customer.retrieve(current_user.stripe_id)
      subscription = customer.subscriptions.retrieve(current_user.stripe_plan_id)
      subscription.plan = plan.id
      subscription.save

    elsif current_user.card?

      customer = Stripe::Customer.retrieve(current_user.stripe_id)
      customer.subscriptions.create(plan: plan)

    else

      customer = Stripe::Customer.create(
        email: current_user.email,
        source: {
          object: 'card',
          number: params[:user][:card_number],
          exp_month: params[:user][:exp_month],
          exp_year: params[:user][:exp_year],
          cvc: params[:user][:cvc_number],
        },
        plan: params[:id],
        description: "MarketplaceBase: #{plan.name}"
      )

      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      current_user.update_attributes(stripe_plan_id: customer.subscriptions.data[0].id , stripe_plan_name: plan.name, role: 'merchant', stripe_id: customer.id, card_number: @crypt.encrypt_and_sign(params[:user][:card_number]), exp_year: params[:user][:exp_year], exp_month: params[:user][:exp_month], cvc_number: params[:user][:cvc_number])

    end
    #make sure to tie in subscriptions with charges so users dont have to put in CC info again
    redirect_to root_path, notice: "You Joined Plan #{plan.name.titleize}"
  end
end
