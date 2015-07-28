class OrdersController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  def index
    @purchases = Order.all.where(user_id: current_user.id).order("refunded or paid DESC").where(active: true)
    @suspended = Order.all.where(user_id: current_user.id).where(active: false)
    @orders = Order.all.where(merchant_id: current_user.id).order("created_at DESC").where(paid: true)
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
    
    if params[:add_order]
      @order = current_user.orders.find_by(uuid: params[:add_order].partition('--').last)
    end
    if params[:shipping_option]
      @shipping_option =  (params[:shipping_option].to_i / 100)
    else
      @shipping_option = @order.shipping_price
    end
    @ship_to = params[:ship_to]
    
    if @quantity <= @product.quantity && @quantity > 0

      if @current_orders.present? && !@order.nil? && @order.status == "Pending Submission"
        if params[:ship_to]
          @add_order = current_user.orders.find_by(ship_to: params[:ship_to])
        else
          @add_order = current_user.orders.find_by(uuid: params[:add_order].partition('--').last)
        end

        @merchant_id = @current_orders.map(&:merchant_id).uniq
        
        if @merchant_id.size == 1 && @merchant_id.join("").to_i == @product.user_id && @order.ship_to == @add_order.ship_to && @order.status == "Pending Submission"
          
          if @order.order_items.map(&:title).include? @product.title
            @item = @order.order_items.find_by(title: @product.title)
            @new_q = @item.quantity.to_i + @quantity
            @new_o = current_user.orders.find_by(uuid: params[:add_order].partition('--').last)
            
            @item.update_attributes(quantity: @new_q, price: (@product.price * @new_q))
            
            @order.update_attributes(total_price: Order.total_price(@new_o, @shipping_option))
          else
            @order.order_items.create(title: @product.title, price: (@product.price * @quantity), 
                                      user_id: @product.user_id, uuid: @product.uuid,
                                      quantity: @quantity )
            @order.update_attributes(total_price: Order.total_price(@order, @shipping_option))
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
        @order = Order.new
        if @order.save
          if @shipping_option
            if @ship_to
              
              @order.update_attributes(active: true, status: "Pending Submission", ship_to: @ship_to,
                                       customer_name: current_user.email,shipping_option: @product.shipping_options.find_by(price: (@shipping_option)).title,
                                       user_id: current_user.id, shipping_price: @product.shipping_options.find_by(price: @shipping_option).price,
                                       merchant_id: @product.user_id, uuid: SecureRandom.uuid)
            else
              redirect_to @product
              flash[:error] = 'Please Select Shipping Address'
              return
            end
          else
            redirect_to @product
            flash[:error] = 'Please Select Shipping Option'
            return
          end

          @order.order_items.create!(title: "#{@product.title}", price: (@product.price * @quantity), user_id: @product.user_id, uuid: @product.uuid,
                                 quantity: @quantity)
          
          @order.update_attributes(total_price: Order.total_price(@order, @shipping_option))
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
    @order.update_attributes(active: true)
    redirect_to orders_url, notice: 'Order was successfully restarted.'
  end

  # DELETE /orders/1
  def destroy
    @order.update_attributes(active: false)
    redirect_to orders_url, notice: 'Order was successfully suspended.'
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
                                    :total_price, :user_id, order_items_attributes: [:id, :title, :price, :user_id, :uuid, :description, :quantity, :_destroy])
    end
end
