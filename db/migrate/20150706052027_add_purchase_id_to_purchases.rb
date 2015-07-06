class AddPurchaseIdToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :purchase_id, :string
  end
end
