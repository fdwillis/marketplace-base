class RefundsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @refunds = Refund.all.where(merchant_id: current_user.id).where(status: "Pending")
  end
  def create
    #Test refund for admin, might need to filter because admin doesnt have merchant_secret field
    #Track With Keen "refund requests"
    # let merchants handle refunds
    order = Order.find_by(uuid: params[:uuid])
    if order.refunds.map(&:amount).sum + params[:amount].to_f <= order.total_price
      order.refunds.create(amount: params[:amount], note: params[:note], refunded: false, uuid: SecureRandom.uuid, status: "Pending", merchant_id: order.merchant_id)
    else
      redirect_to orders_path
      flash[:error] = "Your Refund Request Amount Is Too Big"
      return
    end
    redirect_to orders_path
    flash[:alert] = "Your Refund Is Pending"
  end
  def update
    #Track With Keen "refunds fullfilled"
    debugger
    redirect_to refunds_path
    return

    @amount = params[:price].to_i

    @order = Order.find_by(stripe_charge_id: params[:refund_id])

    if User.find(@order.merchant_id).role == 'admin'
      ch = Stripe::Charge.retrieve(params[:refund_id])
      refund = ch.refunds.create(amount: @amount)
    else
      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      Stripe.api_key = @crypt.decrypt_and_verify((User.find(@order.merchant_id)).merchant_secret_key)

      ch = Stripe::Charge.retrieve(params[:refund_id])
      refund = ch.refunds.create(refund_application_fee: true, amount: @amount)

      Stripe.api_key = Rails.configuration.stripe[:secret_key]
    end

    @order.order_items.each do |oi|
      @product = Product.find_by(uuid: oi.uuid)
      @product.update_attributes(quantity: @product.quantity + oi.quantity.to_i)
    end

    order.update_attributes(status: "Refunded", refunded: true)
    redirect_to refunds_path, notice: "Refund Fullfilled"
  end
end

