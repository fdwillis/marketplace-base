class AddRefundAmountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :refund_amount, :decimal, default: 0.0
  end
end
