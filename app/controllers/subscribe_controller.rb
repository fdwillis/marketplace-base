class SubscribeController < ApplicationController
before_filter :authenticate_user!

  def update
    plan = Stripe::Plan.retrieve(params[:id])

    if current_user.stripe_plan_id?  

      customer = Stripe::Customer.retrieve(current_user.stripe_id)
      subscription = customer.subscriptions.retrieve(current_user.stripe_plan_id)
      
      subscription.plan = plan.id
      subscription.save

      current_user.update_attributes(stripe_plan_name: plan.name)
      redirect_to root_path, notice: "You Joined Plan #{plan.name.titleize}"

    elsif current_user.card?

      customer = Stripe::Customer.retrieve(current_user.stripe_id)
      subscription = customer.subscriptions.create(plan: plan)

      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      current_user.update_attributes(stripe_plan_id: subscription.id , stripe_plan_name: plan.name, role: 'merchant')
      redirect_to root_path, notice: "You Joined Plan #{plan.name.titleize}"

    else
      redirect_to edit_user_registration_path
      flash[:error] = "Please Add A Credit Card"
    end
  end
end
