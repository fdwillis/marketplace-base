class AddCarrierToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :carrier, :string
  end
end
