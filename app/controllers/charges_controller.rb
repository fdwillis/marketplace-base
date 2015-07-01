class ChargesController < ApplicationController
  before_filter :authenticate_user!
  def new
  end

  def create
    # Track with Keen
    if current_user.purchases.map(&:product_id).include? params[:product_id].to_i && (current_user.purchases.empty? || current_user.purchases.find_by(uuid: params[:uuid]).refunded?)
      flash[:error] = "You've Already Purchased This"
      redirect_to root_path
    else
      
        @price = params[:price].to_i
        @fee = (@price * (350)/100) / 100
        @merchant60 = ((@price) * 60) /100
        @admin40 = (@price - @merchant60)

      if current_user.card?
        if !current_user.stripe_id?
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
          current_user.update_attributes(stripe_id: customer.id)
          current_user.save!

          charge = Stripe::Charge.create(
           customer:    current_user.stripe_id,
           amount:      @price + @fee,
           description: 'Rails Stripe customer',
           currency:    'usd'

          )
          Purchase.create(uuid: params[:uuid], merchant_id: params[:merchant_id], stripe_charge_id: charge.id,
                          title: params[:title], price: params[:price],
                          user_id: current_user.id, product_id: params[:product_id],
                          product_image: params[:product_image]
          )
          redirect_to root_path, notice: "Thanks for the purchase!"
        
          merchant = User.find(params[:merchant_id])
          merchant.pending_payment += @merchant60
          merchant.save!

          admin = User.find_by(role: "admin")
          admin.pending_payment += (@admin40)
          admin.save!

        else
          charge = Stripe::Charge.create(
           customer:    current_user.stripe_id,
           amount:      @price + @fee,
           description: 'Rails Stripe customer',
           currency:    'usd'

          )
          Purchase.create(uuid: params[:uuid], merchant_id: params[:merchant_id], stripe_charge_id: charge.id,
                          title: params[:title], price: params[:price],
                          user_id: current_user.id, product_id: params[:product_id],
                          product_image: params[:product_image]
          )
          redirect_to root_path, notice: "Thanks for the purchase!"
                #Track this event through Keen
                    
          merchant = User.find(params[:merchant_id])
          merchant.pending_payment += @merchant60
          merchant.save!

          admin = User.find_by(role: "admin")
          admin.pending_payment += (@admin40)
          admin.save!

        end
      else
        redirect_to edit_user_registration_path
        flash[:error] = "Please Add Card Details"
      end
    end
  end
end
