class AddMerchantApprovedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :account_approved, :boolean, default: nil
  end
end
