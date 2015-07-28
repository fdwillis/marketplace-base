class AddOrderIdToShippingUpdate < ActiveRecord::Migration
  def change
    add_reference :shipping_updates, :order, index: true
    add_foreign_key :shipping_updates, :orders
  end
end
