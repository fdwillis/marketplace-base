class AddMerchantIdToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :merchant_id, :integer
  end
end
