class AddShipToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :ship_to, :string
  end
end
