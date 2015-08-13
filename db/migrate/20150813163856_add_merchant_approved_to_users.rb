class AddMerchantApprovedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :merchant_approved, :boolean, default: false
  end
end
