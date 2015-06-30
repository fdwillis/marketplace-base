class AddPendingAmountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pending_payment, :integer, default: 0
  end
end
