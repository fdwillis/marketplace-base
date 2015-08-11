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

    if params[:full_refund]
      @refund = order.refunds.create_with(note: params[:full_refund_note].downcase, refunded: false, uuid: SecureRandom.uuid , status: "Pending").find_or_create_by(order_uuid: order.uuid, amount: order.total_price, merchant_id: order.merchant_id)
      @refund.save!
    else

      @amount = []

      params[:amount].each do |amount|
        @amount << amount.to_f
      end

      @refund_amount = @amount.sum

      if order.refunds.map(&:amount).sum + @refund_amount <= order.total_price

        @refund = order.refunds.create_with(refunded: false, uuid: SecureRandom.uuid, status: "Pending").find_or_create_by(order_uuid: order.uuid, amount: @refund_amount , merchant_id: order.merchant_id)
        
        params[:uuids].each_with_index do |uuid, index|

          @product_return_amount = params[:amount][index].to_f

          @return_item = Product.find_by(uuid: uuid)

          @refund.returned_products.find_or_create_by(note: params[:note][index], title: @return_item.title, price: @product_return_amount, uuid: SecureRandom.uuid)
        end

      else
        redirect_to orders_path
        flash[:error] = "Your Refund Request Amount Is Too Big"
        return
      end
    end
    redirect_to orders_path
    flash[:alert] = "Your Refund Is Pending"
  end
  def update
    #Track With Keen "refunds fullfilled"

    @amount = ((params[:refund_amount].to_f) * 100).to_i

    @order = Order.find_by(stripe_charge_id: params[:refund_id])
    if User.find(@order.merchant_id).role == 'admin'
      ch = Stripe::Charge.retrieve(params[:refund_id])
      refund = ch.refunds.create(amount: @amount)
    else

      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      Stripe.api_key = @crypt.decrypt_and_verify((User.find(@order.merchant_id)).merchant_secret_key)

      ch = Stripe::Charge.retrieve(params[:refund_id])
      
      begin
        refund = ch.refunds.create(refund_application_fee: true, amount: @amount)
      rescue => e
        redirect_to refunds_path
        flash[:error] = "#{e}"
        return
      end
      @order.update_attributes(refund_amount: ((@amount) / 100))


      if @order.total_price == ((@amount.to_f) / 100)
        @order.update_attributes(status: "Refunded", refunded: true)
      end

      if @order.stripe_shipping_charge.present?
        Stripe.api_key = Rails.configuration.stripe[:secret_key]
        
        ch = Stripe::Charge.retrieve(@order.stripe_shipping_charge)
        refund = ch.refunds.create(amount: ch.amount)
      end

      @order.order_items.each do |oi|
        @product = Product.find_by(uuid: oi.uuid)
        @product.update_attributes(quantity: @product.quantity + oi.quantity.to_i)
      end

      Stripe.api_key = Rails.configuration.stripe[:secret_key]
      sleep 1

      @order.refunds.first.update_attributes(status: 'Refunded', refunded: true)
      redirect_to refunds_path
      flash[:notice] = "Refund Fullfilled"
      return
      
    end
  end
end

