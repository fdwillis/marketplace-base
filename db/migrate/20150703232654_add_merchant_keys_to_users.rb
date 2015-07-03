class AddMerchantKeysToUsers < ActiveRecord::Migration
  def change
    add_column :users, :merchant_secret_key, :string
    add_column :users, :merchant_publishable_key, :string
  end
end
