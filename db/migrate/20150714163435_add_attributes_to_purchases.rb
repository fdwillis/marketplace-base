class AddAttributesToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :quantity, :integer
    add_column :purchases, :description, :text
  end
end
