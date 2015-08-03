class OrdersController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_order, only: [:show, :edit, :update, :destroy, :active_order]

  # GET /orders
  def index
    @purchases = Order.all.where(user_id: current_user.id).order("refunded or paid DESC").where(active: true)
    @suspended = Order.all.where(user_id: current_user.id).where(active: false)
    @orders = Order.all.where(merchant_id: current_user.id).order("updated_at ASC").where(paid: true)
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

    if params[:ship_to]  
      if params[:ship_to].include? '_new'
        @order = Order.new
        @ship_to = params[:ship_to].gsub("_new", "")
      else params[:ship_to]
        @order = current_user.orders.find_by(ship_to: params[:ship_to])
      end
    else
      if params[:add_order]
        @order = current_user.orders.find_by(uuid: params[:add_order].partition('--').last)
      else
        redirect_to @product
        flash[:error] = "Please Choose A Shipping Destination"
        return
      end
    end
    
    if @quantity <= @product.quantity && @quantity > 0
      if @current_orders.present? && !@order.nil? && @order.status == "Pending Submission"

        @add_order = current_user.orders.find_by(uuid: params[:add_order].partition('--').last)
        @merchant_id = @current_orders.map(&:merchant_id).uniq
        
        if @merchant_id.size == 1 && @merchant_id.join("").to_i == @product.user_id && @order.ship_to == @add_order.ship_to && @order.status == "Pending Submission"
          
          if @order.order_items.map(&:title).include? @product.title
            @item = @order.order_items.find_by(title: @product.title)
            @new_q = @item.quantity.to_i + @quantity

            @item.update_attributes(quantity: @new_q, price: @product.price, total_price: @new_q * @product.price)

            @order = @add_order
            @order.update_attributes(total_price: Order.total_price(@order), shipping_price: Order.shipping_price(@order))
          else
            @order.order_items.create(title: @product.title, price: @product.price, 
                                      user_id: @product.user_id, uuid: @product.uuid,
                                      quantity: @quantity, shipping_price: @product.shipping_price, total_price: @quantity * @product.price )

            @order.update_attributes(total_price: Order.total_price(@order), shipping_price: Order.shipping_price(@order))
          end
          
          redirect_to root_path
          flash[:notice] = "Added #{@product.title} To Your Cart"
          return
        else
          redirect_to @product
          flash[:error] = "Please start a new order"
          return
        end
      else
        if @order.save
          if @ship_to

            @order.order_items.create!(title: "#{@product.title}", price:@product.price, user_id: @product.user_id, uuid: @product.uuid,
                                 quantity: @quantity, shipping_price: @product.shipping_price, total_price: @product.price * @quantity)

            Order.shipping_price(@order)

            @order.update_attributes(active: true, status: "Pending Submission", ship_to: @ship_to,
                                     customer_name: current_user.email,
                                     user_id: current_user.id, shipping_price: Order.shipping_price(@order),
                                     merchant_id: @product.user_id, uuid: SecureRandom.uuid)
          else
            redirect_to @product
            flash[:error] = 'Please Select Shipping Address'
            return
          end
          
          @order.update_attributes(total_price: Order.total_price(@order))
          @order.save
          redirect_to root_path
          flash[:notice] = 'Order was successfully saved.'
          return
        else
         render :new
        end
      end
    else
      redirect_to @product
      flash[:error] = 'Please Select Quantity'
      return
    end
  end

  # PATCH/PUT /orders/1
  def update
    
    @tracking_number = params[:tracking_number]
    @order.update_attributes(tracking_number: @tracking_number)
    AfterShip.api_key = ENV['AFTERSHIP_KEY']

    @s = AfterShip::V4::Tracking.create( @tracking_number, {:emails => ["#{@order.customer_name}"]})
    
    @order.update_attributes(tracking_number: @tracking_number, carrier: @s['data']['tracking']['slug'])
    redirect_to orders_url, notice: 'Tracking Number Was Successfully Added.'
  end
  def active_order
    
    @order.update_attributes(active: true)
    redirect_to orders_url, notice: 'Order was successfully restarted.'
  end

  # DELETE /orders/1
  def destroy
    @order.update_attributes(active: false)
    redirect_to orders_url, notice: 'Order Was Successfully Saved.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:active, :uuid, :application_fee, :stripe_charge_id, :purchase_id,
                                    :carrier, :refunded,
                                    :merchant_id, :paid, :shipping_price, :status, :ship_to, 
                                    :customer_name, :tracking_number, :shipping_option, 
                                    :total_price, :user_id, order_items_attributes: [:id, :title, :price, :total_price, :user_id, :uuid, :description, :quantity, :_destroy],
                                    shipping_updates_attributes: [:id, :message, :checkpoint_time, :tag, :order_id, :_destroy])
    end
end
