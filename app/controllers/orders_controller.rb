class OrdersController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  def index
    @purchases = Order.all.where(user_id: current_user.id).order("refunded ASC")
    @orders = Order.all.where(merchant_id: current_user.id).order("created_at DESC")
  end

  # GET /orders/1
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  def create
    @product = Product.find_by(uuid: params[:uuid])
    @quantity = params[:quantity].to_i
    @current_orders = current_user.orders
    debugger
    if @current_orders.present?
      @order = current_user.orders.find_by(ship_to: params[:add_order])
      @total_price = @order.product_price
      @add_order = params[:add_order]
      @merchant_id = @current_orders.map(&:merchant_id).uniq

      if @merchant_id.size == 1 && @merchant_id.join("").to_i == @product.user_id && @order.ship_to == @add_order && @order.status == "Pending Submission"
        @order.order_items.create(title: @product.title, price: (@product.price * @quantity), 
                                  user_id: @product.user_id, uuid: @product.uuid,
                                  quantity: @quantity )
        redirect_to root_path
        flash[:notice] = "Added #{@product.title} To Your Cart"
      else
        redirect_to @product
        flash[:error] = "Please start a new order"
      end
    else
      @order = Order.new
      if @order.save
        @order.update_attributes(status: "Pending Submission", ship_to: params[:ship_to],
                                 customer_name: current_user.email,shipping_option: @product.shipping_options.find_by(price: (params[:shipping_option].to_f/100)).title,
                                 total_price: (@quantity * @product.price) , user_id: current_user.id, paid: true,
                                 shipping_price: @product.shipping_options.find_by(price: (params[:shipping_option].to_f/100)).price,
                                 merchant_id: @product.user_id, uuid: SecureRandom.uuid)

        @order.order_items.create!(title: "#{@product.title}", price: @product.price, user_id: @product.user_id, uuid: @product.uuid,
                               quantity: @quantity)
        @order.save
       redirect_to root_path, notice: 'Order was successfully saved.'
      else
       render :new
      end
    end
  end

  # PATCH/PUT /orders/1
  def update
    if @order.update(order_params)
     redirect_to @order, notice: 'Order was successfully updated.'
    else
     render :edit
    end
  end

  # DELETE /orders/1
  def destroy
    @order.destroy
   redirect_to orders_url, notice: 'Order was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:uuid, :application_fee, :stripe_charge_id, :purchase_id,
                                    :carrier, :refunded,
                                    :merchant_id, :paid, :shipping_price, :status, :ship_to, 
                                    :customer_name, :tracking_number, :shipping_option, 
                                    :total_price, :user_id, order_items_attributes: [:id, :title, :price, :user_id, :uuid, :description, :quantity, :_destroy])
    end
end
