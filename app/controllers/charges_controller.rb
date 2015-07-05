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

      if current_user.card? || current_user.stripe_id?
        @card = @crypt.decrypt_and_verify(current_user.card_number)
        @stripe_account_id = @crypt.decrypt_and_verify(User.find(Product.find_by(uuid: params[:uuid]).user_id).stripe_account_id)
        debugger
        @token = Stripe::Token.create(
          :card => {
            :number => @card,
            :exp_month => current_user.exp_month,
            :exp_year => current_user.exp_year,
            :cvc => current_user.cvc_number
          },
        )

        if !current_user.stripe_id?
          begin
            charge = User.charge_n_create(params[:price].to_i, @token, @stripe_account_id, current_user.email)
            redirect_to root_path
            flash[:notice] = "Thanks for the purchase!"

            Purchase.create(uuid: params[:uuid], merchant_id: params[:merchant_id], stripe_charge_id: charge.id,
                            title: params[:title], price: params[:price],
                            user_id: current_user.id, product_id: params[:product_id],
                            application_fee: charge.application_fee,
            )

          rescue Stripe::CardError => e
            # CardError; display an error message.
            redirect_to edit_user_registration_path
            flash[:error] = 'Card Details Not Valid'
          end
        else  
          #Track this event through Keen
          begin
            charge = User.charge_n_process(params[:price].to_i, @token, @stripe_account_id, current_user.email)
            redirect_to root_path
            flash[:notice] = "Thanks for the purchase!"

            Purchase.create(uuid: params[:uuid], merchant_id: params[:merchant_id], stripe_charge_id: charge.id,
                            title: params[:title], price: params[:price],
                            user_id: current_user.id, product_id: params[:product_id],
                            application_fee: charge.application_fee,
            )
          rescue Stripe::CardError => e
            # CardError; display an error message.
            redirect_to edit_user_registration_path
            flash[:error] = 'Card Details Not Valid'
          rescue => e
            # Some other error; display an error message.
            redirect_to edit_user_registration_path
            flash[:notice] = 'Some error occurred.'
          end

        end
      else
        redirect_to edit_user_registration_path
        flash[:error] = "Please Add Credit Card Details"
      end
    end
  end
end
