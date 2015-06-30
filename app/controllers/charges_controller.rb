class ChargesController < ApplicationController
  def new
  end

  def create
    # Amount in cents
    @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
    @card = @crypt.decrypt_and_verify(current_user.card_number)

    customer = Stripe::Customer.create(
      email: current_user.email,
      source: {
        object: 'card',
        number: @card,
        exp_month: current_user.exp_month,
        exp_year: current_user.exp_year,
        cvc: current_user.cvc_number,
       },
    )

    debugger
    charge = Stripe::Charge.create(
     customer:    customer.id,
     amount:      params[:amount].to_i,
     description: 'Rails Stripe customer',
     currency:    'usd'
    )
    redirect_to root_path, notice: "Thanks for the purchase!"
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to charges_path
  end
end
