class AddShippingInfoToProducts < ActiveRecord::Migration
  def change
    add_column :products, :shipping_title, :string
    add_column :products, :shipping_price, :decimal, precision: 12, scale: 2
  end
end
