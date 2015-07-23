class AddMerchIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :merchant_id, :integer
  end
end
