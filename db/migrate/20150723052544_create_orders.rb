class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :status
      t.string :ship_to
      t.string :customer_name
      t.string :tracking_number, default: "Waiting For Tracking Number"
      t.string :shipping_option
      t.decimal :total_price, precision: 12, scale: 2

      t.timestamps null: false
    end
  end
end
