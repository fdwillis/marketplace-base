class PurchasesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @purchases = Purchase.all.where(user_id: current_user.id).order("refunded ASC")
    @orders = Purchase.all.where(merchant_id: current_user.id)
  end
  def create
    #Track with Keen for Merchant & Admin
    #Time between purchases for customers in hours
    #Track product tags as well with Keen
    #Grab country of the card by switching to the merchant and using Stripe::Charge.retrieve(charge_id).source.country
    if !current_user.purchases.find_by(purchase_id: params[:purchase_id]).nil? && !current_user.purchases.find_by(purchase_id: params[:purchase_id]).refunded?
      flash[:error] = "You've Already Purchased This"
      redirect_to root_path
    else
      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      @price = params[:price].to_i

      if current_user.card?
        @card = @crypt.decrypt_and_verify(current_user.card_number)
        if User.find(Product.find_by(uuid: params[:uuid]).user_id).stripe_account_id
          
          @currency = User.find(Product.find_by(uuid: params[:uuid]).user_id).currency
          @stripe_account_id = @crypt.decrypt_and_verify(User.find(Product.find_by(uuid: params[:uuid]).user_id).stripe_account_id)
          @shipping = params[:shipping_option].to_i
          @shipping_name = Product.find_by(uuid: params[:uuid]).shipping_options.find_by(price: (params[:shipping_option].to_f/100)).title
          @ship_to = params[:ship_to]
        end
        begin
          @token = Stripe::Token.create(
            card: {
              number: @card,
              exp_month: current_user.exp_month,
              exp_year: current_user.exp_year,
              cvc: current_user.cvc_number,
              name: current_user.legal_name,
              address_city: current_user.address_city,
              address_zip: current_user.address_zip,
              address_state: current_user.address_state,
              address_country: current_user.country_name,
            },
          )
        rescue Stripe::CardError => e
          redirect_to edit_user_registration_path
          flash[:error] = "#{e}"
          return
        rescue => e
          redirect_to edit_user_registration_path
          flash[:error] = "#{e}"
          return
        end

        if params[:refund_agreement]
          if params[:shipping_option]
            if Product.find_by(uuid: params[:uuid]).user.role == 'admin'
              begin
                @charge = User.charge_for_admin(@price, @token.id, @shipping)
                redirect_to root_path
                flash[:notice] = "Thanks for the purchase!"
                Purchase.create(uuid: params[:uuid], merchant_id: params[:merchant_id], stripe_charge_id: @charge.id,
                                  title: params[:title], price: params[:price],
                                  user_id: current_user.id, product_id: params[:product_id],
                                  application_fee: 0, purchase_id: SecureRandom.uuid,
                                  status: 'Paid', shipping_option: @shipping_name, ship_to: @ship_to,
                  )
                return
              rescue Stripe::CardError => e
                redirect_to edit_user_registration_path
                flash[:error] = "#{e}"
                return
              rescue => e
                redirect_to edit_user_registration_path
                flash[:error] = "#{e}"
                return
              end
            else
              begin
                
                @charge = User.charge_n_process(@price, @token, @stripe_account_id, @currency, @shipping)
                
                redirect_to root_path
                flash[:notice] = "Thanks for the purchase!"
                Purchase.create(uuid: params[:uuid], merchant_id: params[:merchant_id], stripe_charge_id: @charge.id,
                                  title: params[:title], price: params[:price],
                                  user_id: current_user.id, product_id: params[:product_id],
                                  application_fee: @charge.application_fee, purchase_id: SecureRandom.uuid,
                                  status: 'Paid', shipping_option: @shipping_name, ship_to: @ship_to,
                  )
                return
              rescue Stripe::CardError => e
                redirect_to edit_user_registration_path
                flash[:error] = "#{e}"
                return
              rescue => e
                redirect_to edit_user_registration_path
                flash[:error] = "#{e}"
                return
              end
            end
          else
            redirect_to product_path(params[:product_id])
            flash[:error] = "Please Choose A Shipping Option"
          end
        else
          redirect_to product_path(params[:product_id])
          flash[:error] = "Plese Agree To The Sellers Return Policy"
        end
      else
        redirect_to edit_user_registration_path
        flash[:error] = "You Are Missing Credit Card Details Or Shipping Information"
        return
      end
    end
  end

private
  # Never trust parameters from the scary internet, only allow the white list through.
  def purchase_params
    params.require(:purchase).permit(:ship_to, :shipping_option, :quantity, :description, :title, :price, :uuid, :user_id, :product_id, :refunded, :stripe_charge_id, :merchant_id, :application_fee, :purchase_id, :status)
  end
end
