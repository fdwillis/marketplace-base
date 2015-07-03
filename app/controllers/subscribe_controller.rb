class SubscribeController < ApplicationController
  def new
    unless (params[:plan_name] == "basic" || params[:plan_name] == "advanced" || params[:plan_name] == "pro")
      flash[:notice] = "Please select a plan to get started."
      redirect_to root_path
    end
  end

  def update
    customer = Stripe::Customer.create(
      email: current_user.email,
      source: {
        object: 'card',
        number: params[:card_number],
        exp_month: params[:exp_month],
        exp_year: params[:exp_year],
        cvc: params[:cvc_number],
      },
      plan: params[:id],
      description: 'MarkeplaceBase'
    )

    #make sure to tie in subscriptions with charges so users dont have to put in CC info again
    @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
    current_user.update_attributes(card_number: @crypt.encrypt_and_sign(params[:card_number]), exp_year: exp_month: cvc_number: )
  end
end
