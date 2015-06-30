class ChargesController < ApplicationController
  before_filter :authenticate_user!
  def new
  end

  def create
    if current_user.card_number?  
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

      charge = Stripe::Charge.create(
       customer:    customer.id,
       amount:      params[:price].to_i,
       description: 'Rails Stripe customer',
       currency:    'usd'
      )
      #Track this event through Keen
      merchant60 = (params[:price].to_i * 60) / 100
      admin40 = params[:price].to_i - merchant60
      
      merchant = User.find(params[:merchant_id])
      merchant.pending_payment += merchant60
      merchant.save!

      admin = User.find_by(role: "admin")
      admin.pending_payment += admin40
      admin.save!

      Purchase.create(title: params[:title], price: params[:price], user_id: current_user.id, product_id: params[:product_id], product_image: params[:product_image])
      redirect_to root_path, notice: "Thanks for the purchase!"
    else
      redirect_to edit_user_registration_path
      flash[:error] = "Please Add Card Details"
    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to charges_path
  end
end
