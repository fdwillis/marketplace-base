class AddShippingOptionToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :shipping_option, :string
  end
end
