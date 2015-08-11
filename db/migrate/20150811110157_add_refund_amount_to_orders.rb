class AddRefundAmountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :refund_amount, :decimal
  end
end
