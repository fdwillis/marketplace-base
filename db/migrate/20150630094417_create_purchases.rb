class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.string :title
      t.integer :price
      t.belongs_to :user, index: true
      t.belongs_to :product, index: true
      t.boolean :refunded, default: :false

      t.timestamps null: false
    end
    add_foreign_key :purchases, :users
    add_foreign_key :purchases, :products
  end
end
