class ChargesController < ApplicationController
  before_filter :authenticate_user!

  # def new
  # end

  def create
    # Track with Keen
    if current_user.purchases.map(&:product_id).include? params[:product_id].to_i && (current_user.purchases.empty? || current_user.purchases.find_by(uuid: params[:uuid]).nil? || current_user.purchases.find_by(uuid: params[:uuid]).refunded?)
      flash[:error] = "You've Already Purchased This"
      redirect_to root_path
    else
      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      @price = params[:price].to_i
      @fee = (@price * (350) / 100) / 100
      @merchant60 = ((@price) * 60) /100
      @admin40 = (@price - @merchant60)


      if current_user.card? || current_user.stripe_id?
        @card = @crypt.decrypt_and_verify(current_user.card_number)
        @stripe_account_id = @crypt.decrypt_and_verify(User.find(Product.find_by(uuid: params[:uuid]).user_id).stripe_account_id)
        if !current_user.stripe_id?

          token = Stripe::Token.create(
            :card => {
              :number => @card,
              :exp_month => current_user.exp_month,
              :exp_year => current_user.exp_year,
              :cvc => current_user.cvc_number
            },
          )
          charge = User.charge_n_create(params[:price].to_i, token, @stripe_account_id, current_user.email, current_user)

          Purchase.create(uuid: params[:uuid], merchant_id: params[:merchant_id], stripe_charge_id: charge.id,
                          title: params[:title], price: params[:price],
                          user_id: current_user.id, product_id: params[:product_id],
                          application_fee: charge.application_fee,
          )
          redirect_to root_path, notice: "Thanks for the purchase!"
        
          merchant = User.find(params[:merchant_id])
          merchant.pending_payment += @merchant60
          merchant.save!

          admin = User.find_by(role: "admin")
          admin.pending_payment += (@admin40)
          admin.save!

        else  
          charge = User.charge_n_process(params[:price].to_i, token, @stripe_account_id, current_user.email)

          Purchase.create(uuid: params[:uuid], merchant_id: params[:merchant_id], stripe_charge_id: charge.id,
                          title: params[:title], price: params[:price],
                          user_id: current_user.id, product_id: params[:product_id],
                          application_fee: charge.application_fee,
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
        flash[:error] = "Please Add Credit Card Details"
      end
    end
  end
end
