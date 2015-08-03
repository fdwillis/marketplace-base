class AddShippingPriceToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :shipping_price, :decimal
  end
end
