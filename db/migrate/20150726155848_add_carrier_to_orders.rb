class AddCarrierToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :carrier, :string, default: "Waiting For Tracking Number"
  end
end
