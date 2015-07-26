class AddRefundedToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :refunded, :boolean
  end
end
