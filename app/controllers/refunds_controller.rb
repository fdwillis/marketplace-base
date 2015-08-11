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
      @check_refund = order.refunds.map(&:amount_issued).sum.to_f + @refund_amount
      
      
      if @check_refund <= order.total_price

        @refund = order.refunds.create_with(refunded: false, uuid: SecureRandom.uuid, status: "Pending").find_or_create_by(order_uuid: order.uuid, amount: @refund_amount , merchant_id: order.merchant_id)
        
        params[:uuids].each_with_index do |uuid, index|

          @product_return_amount = params[:amount][index].to_f

          @return_item = Product.find_by(uuid: uuid)

          @refund.returned_products.find_or_create_by(note: params[:note][index], title: @return_item.title, price: @product_return_amount, uuid: SecureRandom.uuid)
        end

      else
        redirect_to orders_path
        flash[:error] = "Available For Refund: $#{order.total_price - order.refund_amount}"
        return
      end
    end
    redirect_to orders_path
    flash[:alert] = "Your Refund Is Pending"
  end

  def update
    #Track With Keen "refunds fullfilled"

    @amount = params[:refund_amount].to_f
    @stripe_amount = ((params[:refund_amount].to_f) * 100).to_i

    @order = Order.find_by(stripe_charge_id: params[:refund_id])
    
    if User.find(@order.merchant_id).role == 'admin'
      ch = Stripe::Charge.retrieve(params[:refund_id])

      begin
        refund = ch.refunds.create(amount: @stripe_amount)

        @order.update_attributes(refund_amount: (@amount + @order.refund_amount))

        if @order.total_price == @amount
          @order.update_attributes(status: "Refunded", refunded: true)
        end

        if @order.stripe_shipping_charge.present?
          Stripe.api_key = Rails.configuration.stripe[:secret_key]
          
          ch = Stripe::Charge.retrieve(@order.stripe_shipping_charge)
          refund = ch.refunds.create(amount: ch.amount)
        end

        # @order.order_items.each do |oi|
        #   @product = Product.find_by(uuid: oi.uuid)
        #   @product.update_attributes(quantity: @product.quantity + oi.quantity.to_i)
        # end

        Stripe.api_key = Rails.configuration.stripe[:secret_key]

        @order.refunds.first.update_attributes(status: 'Refunded', refunded: true)
        redirect_to refunds_path
        flash[:notice] = "Refund Fullfilled"
        return

        rescue => e
          redirect_to refunds_path
          flash[:error] = "#{e}"
          return
        end

    else
      
      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      Stripe.api_key = @crypt.decrypt_and_verify((User.find(@order.merchant_id)).merchant_secret_key)

      ch = Stripe::Charge.retrieve(params[:refund_id])
      
      begin
        refund = ch.refunds.create(refund_application_fee: true, amount: @stripe_amount)
        @order.update_attributes(refund_amount: (@amount + @order.refund_amount))

        if @order.total_price == @amount
          @order.update_attributes(status: "Refunded", refunded: true)
        end

        if @order.stripe_shipping_charge.present?
          Stripe.api_key = Rails.configuration.stripe[:secret_key]
          
          ch = Stripe::Charge.retrieve(@order.stripe_shipping_charge)
          refund = ch.refunds.create(amount: ch.amount)
        end

        # @order.order_items.each do |oi|
        #   @product = Product.find_by(uuid: oi.uuid)
        #   @product.update_attributes(quantity: @product.quantity + oi.quantity.to_i)
        # end

        Stripe.api_key = Rails.configuration.stripe[:secret_key]
        
        @order.refunds.find_by(uuid: params[:refund_uuid] ).update_attributes(status: 'Refunded', refunded: true, amount_issued: @amount)
        redirect_to refunds_path
        flash[:notice] = "Refund Fullfilled"
        return

      rescue => e
        
        redirect_to refunds_path
        flash[:error] = "#{e}"
        return
      end
    end
  end
end

