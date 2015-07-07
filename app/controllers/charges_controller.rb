class ChargesController < ApplicationController
  before_filter :authenticate_user!

  # def new
  # end

  def create
    # Track with Keen
    
    if !current_user.purchases.find_by(purchase_id: params[:purchase_id]).nil? && !current_user.purchases.find_by(purchase_id: params[:purchase_id]).refunded?
      flash[:error] = "You've Already Purchased This"
      redirect_to root_path
    else
      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

      if current_user.card?
        @card = @crypt.decrypt_and_verify(current_user.card_number)
        if User.find(Product.find_by(uuid: params[:uuid]).user_id).stripe_account_id
          @stripe_account_id = @crypt.decrypt_and_verify(User.find(Product.find_by(uuid: params[:uuid]).user_id).stripe_account_id)
        end
        begin
          @token = Stripe::Token.create(
            :card => {
              :number => @card,
              :exp_month => current_user.exp_month,
              :exp_year => current_user.exp_year,
              :cvc => current_user.cvc_number
            },
          )
        rescue Stripe::CardError => e
          # CardError; display an error message.
          redirect_to edit_user_registration_path
          flash[:error] = "#{e}"
          return
        rescue => e
          # Some other error; display an error message.
          redirect_to edit_user_registration_path
          flash[:error] = "#{e}"
          return
        end

        if Product.find_by(uuid: params[:uuid]).user.role == 'admin'
          begin
            @charge = User.charge_for_admin(params[:price].to_i, @token.id)
            redirect_to root_path
            flash[:notice] = "Thanks for the purchase!"
            Purchase.create(uuid: params[:uuid], merchant_id: params[:merchant_id], stripe_charge_id: @charge.id,
                              title: params[:title], price: params[:price],
                              user_id: current_user.id, product_id: params[:product_id],
                              application_fee: 0, purchase_id: SecureRandom.uuid,
              )
            return
          rescue Stripe::CardError => e
            # CardError; display an error message.
            redirect_to edit_user_registration_path
            flash[:error] = "#{e}"
            return
          rescue => e
            # Some other error; display an error message.
            redirect_to edit_user_registration_path
            flash[:error] = "#{e}"
            return
          end
        else
          #Track this event through Keen
          begin
            @charge = User.charge_n_process(params[:price].to_i, @token.id, @stripe_account_id, current_user.email)

            redirect_to root_path
            flash[:notice] = "Thanks for the purchase!"
            Purchase.create(uuid: params[:uuid], merchant_id: params[:merchant_id], stripe_charge_id: @charge.id,
                              title: params[:title], price: params[:price],
                              user_id: current_user.id, product_id: params[:product_id],
                              application_fee: @charge.application_fee, purchase_id: SecureRandom.uuid,
              )
            return
          rescue Stripe::CardError => e
            # CardError; display an error message.
            redirect_to edit_user_registration_path
            flash[:error] = "#{e}"
            return
          rescue => e
            # Some other error; display an error message.
            redirect_to edit_user_registration_path
            flash[:notice] = "#{e}"
            return
          end
        end
      else
        redirect_to edit_user_registration_path
        flash[:error] = "Please Add Credit Card Details"
        return
      end
    end
  end
end
