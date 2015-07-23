class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :status
      t.string :ship_to
      t.string :customer_name
      t.string :tracking_number
      t.string :shipping_option
      t.string :total_price

      t.timestamps null: false
    end
  end
end
