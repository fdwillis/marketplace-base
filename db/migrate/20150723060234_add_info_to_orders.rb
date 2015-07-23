class AddInfoToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :paid, :boolean
    add_column :orders, :shipping_price, :decimal, precision: 12, scale: 2
  end
end
