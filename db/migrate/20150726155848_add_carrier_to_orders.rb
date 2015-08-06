class AddCarrierToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :carrier, :string
  end
end
