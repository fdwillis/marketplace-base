class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.string :title
      t.decimal :price, precision: 12, scale: 2
      t.string :user_id
      t.string :uuid
      t.string :quantity

      t.timestamps null: false
    end
  end
end
