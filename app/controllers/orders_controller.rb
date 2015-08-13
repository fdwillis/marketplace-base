class OrdersController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_order, only: [:update, :destroy, :active_order]

  # GET /orders
  def index
    @pending = Order.all.where(user_id: current_user.id).where(paid: nil)
    @suspended = Order.all.where(user_id: current_user.id).where(active: false)
    @paid = Order.all.where(user_id: current_user.id).where(paid: true).order("updated_at DESC")
    @orders = Order.all.where(merchant_id: current_user.id).order("updated_at DESC").where(paid: true).where(refunded: (false || nil))
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
        if current_user.shipping_addresses.present?
          redirect_to @product
          flash[:error] = "Please Choose A Shipping Destination"
          return
        else
          redirect_to edit_user_registration_path
          flash[:error] = "Please Add A Shipping Address"
          return
        end
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
            @order.order_items.create(product_tags:@product.tag_list.join(", ") , title: @product.title, price: @product.price, 
                                      user_id: @product.user_id, product_uuid: @product.uuid,
                                      quantity: @quantity, shipping_price: @product.shipping_price, total_price: @quantity * @product.price )

            @order.update_attributes(total_price: Order.total_price(@order), shipping_price: Order.shipping_price(@order))
          end
          redirect_to root_path
          flash[:notice] = "Added #{@product.title} To Your Cart"
          return
        else
          redirect_to @product
          flash[:error] = "Please Start a New Order"
          return
        end
      else
        if @order.save
          if @ship_to

            @order.order_items.create(product_tags:@product.tag_list.join(", ") , title: "#{@product.title}", price:@product.price, 
                                      user_id: @product.user_id, product_uuid: @product.uuid, quantity: @quantity, shipping_price: @product.shipping_price, 
                                      total_price: @product.price * @quantity)

            Order.shipping_price(@order)

            @order.update_attributes(active: true, status: "Pending Submission", ship_to: @ship_to,
                                     customer_name: current_user.email,
                                     user_id: current_user.id, shipping_price: Order.shipping_price(@order),
                                     merchant_id: @product.user_id, uuid: SecureRandom.uuid)
          @order.update_attributes(total_price: Order.total_price(@order))
          @order.save
          redirect_to root_path
          flash[:notice] = 'Order Was Successfully Started.'
          return
          else
            redirect_to @product
            flash[:error] = 'Please Select Shipping Address'
            return
          end
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
    @user_order = @order.user
    @shipping_street = @order.ship_to.gsub(/\s+/, "").split(',')[0]
    @shipping = @order.ship_to.gsub(/\s+/, "").split(',')
    @tracking_number = params[:tracking_number]
    if @tracking_number  

      @order.update_attributes(tracking_number: @tracking_number)
      @s = AfterShip::V4::Tracking.create( @tracking_number, {:emails => ["#{@order.customer_name}"]})
      @order.update_attributes(tracking_number: @tracking_number, carrier: @s['data']['tracking']['slug'])
      redirect_to orders_url, notice: 'Tracking Number Was Successfully Added.'
    else

      Shippo.api_token = ENV['SHIPPO_KEY']
      address_from = Shippo::Address.create(
        :object_purpose => "PURCHASE",
        :name => current_user.business_name,
        :company => current_user.business_name,
        :street1 => current_user.address,
        :city => current_user.address_city,
        :state => current_user.address_state,
        :zip => current_user.address_zip,
        :country => current_user.address_country,
        :phone => "+1 #{current_user.support_phone}",
        :email => current_user.email
      )
      
      address_to = Shippo::Address.create(
        :object_purpose => "PURCHASE",
        :name => @user_order.legal_name,
        :street1 => @shipping_street,
        :city => @shipping[1] ,
        :state => @shipping[2] ,
        :zip => @shipping[4],
        :country => @shipping[3],
        phone: @user_order.support_phone,
        :email => @user_order.email,
      )
      
      parcel = Shippo::Parcel.create(
        :length => params[:box_length].to_i,
        :width => params[:box_width].to_i,
        :height => params[:box_height].to_i,
        :distance_unit => :in,
        :weight => params[:box_weight].to_i,
        :mass_unit => :lb,
      )
      shipment = Shippo::Shipment.create(
        :object_purpose => 'PURCHASE',
        :address_from => address_from,
        :address_to => address_to,
        :parcel => parcel
      )

      redirect_to shipping_rates_path(shipment_id: shipment["object_id"], order_uuid: @order.uuid)
    end
  end

  def shipping_rates
    Shippo.api_token = ENV['SHIPPO_KEY']
    shipment_id = params[:shipment_id]
    shipment = Shippo::Shipment.get(shipment_id)
    sleep 3
    @rates = shipment.rates()
    @order_uuid = params[:order_uuid]
  end

  def select_label
    if current_user.merchant_ready?  
      @order = Order.find_by(uuid: params[:order_uuid])
      
      transaction = Shippo::Transaction.create(rate: params[:object_id] )

      sleep 5

      @transaction = Shippo::Transaction.get(transaction["object_id"])

      # label_url and tracking_number
      if @transaction.object_status == "SUCCESS"
        begin
          @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
          @card = @crypt.decrypt_and_verify(current_user.card_number)
          @token = User.new_token(current_user, @card)
        rescue Stripe::CardError => e
          redirect_to edit_user_registration_path
          flash[:error] = "#{e}"
          return
        rescue => e
          redirect_to edit_user_registration_path
          flash[:error] = "#{e}"
          return
        end

        begin
          @shipping_cost = params[:price].to_i
          @charge = User.charge_for_admin(current_user, (@shipping_cost + ((@shipping_cost * 5) / 100).to_i ), @token.id)
          @order.update_attributes(stripe_shipping_charge: @charge.id)
        rescue Stripe::CardError => e
          redirect_to edit_user_registration_path
          flash[:error] = "#{e}"
          return
        rescue => e
          redirect_to edit_user_registration_path
          flash[:error] = "#{e}"
          return
        end

        # @order.shipping_option needs to be the name of the selected label
        
        @order.update_attributes(tracking_url: @transaction.label_url, tracking_number: @transaction.tracking_number, 
                                 carrier: params[:carrier], shipping_option: params[:shipping_option] )
        @tracking_number = AfterShip::V4::Tracking.create( @transaction.tracking_number , {:emails => ["#{@order.customer_name}"]})
        redirect_to orders_path
        flash[:notice] = "Label Sucessfully Generated \nlabel_url: #{@transaction.label_url} \ntracking_number: #{@transaction.tracking_number}" 
        return
      else
        redirect_to orders_path
        flash[:error] = "Error Generating Label"
        puts @transaction.messages
        return
      end
    else
      redirect_to edit_user_registration_path
      flash[:error] = "You are missing a credit card or valid seller information"
    end
  end

  def active_order
    @order.update_attributes(active: true)
    redirect_to orders_url, notice: 'Order Was Successfully Restarted.'
  end

  # DELETE /orders/1
  def destroy
    if params[:action] == 'destroy'
      @order = Order.find_by(uuid: params[:uuid])
      @order.destroy
    else
      @order.update_attributes(active: false)
      flash[:notice] = 'Order Was Successfully Saved.'
    end
    redirect_to orders_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:product_tags, :active, :uuid, :application_fee, :stripe_charge_id, :purchase_id,
                                    :carrier, :refunded, :tracking_url, :stripe_shipping_charge, :merchant_id, :paid, 
                                    :shipping_price, :status, :ship_to, :customer_name, :tracking_number, :shipping_option, 
                                    :total_price, :user_id, order_items_attributes: [:id, :title, :price, :total_price, :user_id, :uuid, :description, :quantity, :_destroy],
                                    shipping_updates_attributes: [:id, :message, :checkpoint_time, :tag, :order_id, :_destroy])
    end
end
