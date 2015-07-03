class SubscribeController < ApplicationController
  def new
    unless (params[:plan_name] == "basic" || params[:plan_name] == "advanced" || params[:plan_name] == "pro")
      flash[:notice] = "Please select a plan to get started."
      redirect_to root_path
    end
  end

  def update
    #make sure to tie in subscriptions with charges so users dont have to put in CC info again
    token = params[:stripeToken]
    customer = Stripe::Customer.create(
      email: params[:stripeEmail],
      card: token,
      plan: params[:id],
      description: 'Windows Of Worlds'
    )
  end
end
