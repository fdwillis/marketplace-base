class AddShippingAddressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :shipping_address, :string
  end
end
