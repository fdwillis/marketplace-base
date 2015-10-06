class Order < ActiveRecord::Base
  belongs_to :user
  after_update :total_price

  has_many :shipping_updates, dependent: :destroy
  has_many :refunds, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :users, through: :order_items
  
  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :shipping_updates, reject_if: :all_blank, allow_destroy: true

  protected

    def self.shipping_price(order)
      @oi_shipping_price = order.order_items.map(&:shipping_price)
      @oi_max = @oi_shipping_price.max

      @total_shipp = []
      order.order_items.each do |oi|
        @total_shipp << oi.shipping_price * oi.quantity
      end
      shipping_price = (@oi_max + ((@total_shipp.sum - @oi_max ) * 0.65 ) ).round(2)
    end
    
    def self.total_price(order)
      @prod_shipp = order.order_items.map(&:total_price).sum + self.shipping_price(order)
      total_price = ((@prod_shipp.to_f.round(2)) + ((@prod_shipp.to_f.round(2)) * User.find(order.merchant_id).tax_rate / 100  ))
    end

    def self.orders_to_keen(order, ip_address, location)
      shipping_to = order.ship_to.gsub(/\s+/, "").split(',')
      shipping_street = order.ship_to.gsub(/\s+/, " ").split(',')[0]

      if !order.application_fee.nil?        
        Keen.publish("Orders", {
          marketplace_name: ENV["MARKETPLACE_NAME"],
          platform_for: 'apparel',
          ip_address: ip_address,
          customer_current_zipcode: location["zipcode"],
          customer_current_city: location["city"] ,
          customer_current_state: location["region_name"],
          customer_current_country: location["country_code"],
          customer_shipping_street: shipping_street,
          customer_shipping_city: shipping_to[1] ,
          customer_shipping_state: shipping_to[2] ,
          customer_shipping_country: shipping_to[3] ,
          customer_shipping_zip: shipping_to[4] ,
          year: Time.now.strftime("%Y").to_i,
          month: DateTime.now.to_date.strftime("%B"),
          day: Time.now.strftime("%d").to_i,
          day_of_week: DateTime.now.to_date.strftime("%A"),
          hour: Time.now.strftime("%H").to_i,
          minute: Time.now.strftime("%M").to_i,
          merchant_id: order.merchant_id.to_i,
          customer_id: order.user.id,
          total_price: order.total_price.to_f,
          shipping_price: order.shipping_price.to_f,
          customer_sign_in_count: order.user.sign_in_count,
          order_uuid: order.uuid,
          timestamp: Time.now,
          application_fee: ((Stripe::ApplicationFee.retrieve(order.application_fee).amount).to_f / 100),
        })
      else 
        Keen.publish("Orders", {
          marketplace_name: ENV["MARKETPLACE_NAME"],
          platform_for: 'apparel',
          ip_address: ip_address,
          customer_current_zipcode: location["zipcode"],
          customer_current_city: location["city"] ,
          customer_current_state: location["region_name"],
          customer_current_country: location["country_code"],
          customer_shipping_street: shipping_street,
          customer_shipping_city: shipping_to[1] ,
          customer_shipping_state: shipping_to[2] ,
          customer_shipping_country: shipping_to[3] ,
          customer_shipping_zip: shipping_to[4] ,
          year: Time.now.strftime("%Y").to_i,
          month: DateTime.now.to_date.strftime("%B"),
          day: Time.now.strftime("%d").to_i,
          day_of_week: DateTime.now.to_date.strftime("%A"),
          hour: Time.now.strftime("%H").to_i,
          minute: Time.now.strftime("%M").to_i,
          merchant_id: order.merchant_id.to_i,
          customer_id: order.user.id,
          total_price: order.total_price.to_f,
          shipping_price: order.shipping_price.to_f,
          customer_sign_in_count: order.user.sign_in_count,
          order_uuid: order.uuid,
          timestamp: Time.now,
        })
      end

      order.order_items.each do |oi|
        Keen.publish("Order Items", {
          marketplace_name: ENV["MARKETPLACE_NAME"],
          platform_for: 'apparel',
          ip_address: ip_address,
          customer_zipcode: location["zipcode"],
          customer_city: location["city"],
          customer_state: location["region_name"],
          customer_country: location["country_code"],
          order_year: Time.now.strftime("%Y").to_i,
          order_month: DateTime.now.to_date.strftime("%B"),
          order_day: Time.now.strftime("%d").to_i,
          order_day_of_week: DateTime.now.to_date.strftime("%A"),
          order_hour: Time.now.strftime("%H").to_i,
          order_minute: Time.now.strftime("%M").to_i,
          product_tags: oi.product_tags,
          price: oi.price.to_f,
          quantity: oi.quantity,
          total_price: oi.total_price.to_f,
          product_uuid: oi.product_uuid,
          order_uuid: oi.order.uuid,
          shipping_price: oi.shipping_price.to_f,
          merchant_id: order.merchant_id.to_i,
          customer_id: order.user.id,
          order_item_id: oi.id,
          order_total_price: oi.total_price,
          customer_sign_in_count: order.user.sign_in_count,
          submitted_to_cart_on: oi.updated_at,
          })
      end
      order.order_items.each do |oi|
        if !Product.find_by(uuid: oi.product_uuid).tags.empty?
          Product.find_by(uuid: oi.product_uuid).tags.each do |tag|
          Keen.publish("Tags On Ordered Items", {
            marketplace_name: ENV["MARKETPLACE_NAME"],
            platform_for: 'apparel',
            tag: tag.name, 
            order_uuid: oi.order.uuid, 
            order_item_id: oi.id,
            order_item_product_uuid: oi.product_uuid,
            order_total_price: oi.order.total_price.to_f,
            order_item_total_price: oi.total_price.to_f, 
          })
          end
        else
          @tags = Keen.publish("Tags On Ordered Items", {
            marketplace_name: ENV["MARKETPLACE_NAME"],
            platform_for: 'apparel',
            tag: "None", 
            order_uuid: oi.order.uuid, 
            order_item_id: oi.id,
            order_item_product_uuid: oi.product_uuid,
            order_total_price: oi.order.total_price.to_f,
            order_item_total_price: oi.total_price.to_f, 
          })
        end
      end
    end
end
