class AddTrackingNumberToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :tracking_number, :string
  end
end
