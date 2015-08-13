class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.string :title
      t.decimal :price, precision: 12, scale: 2
      t.integer :user_id
      t.string :product_uuid
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
