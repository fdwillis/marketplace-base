class AddTrackingUrlToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :tracking_url, :string
  end
end
