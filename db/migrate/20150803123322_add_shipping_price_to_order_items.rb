class AddShippingPriceToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :shipping_price, :decimal, precision: 12, scale: 2
  end
end
