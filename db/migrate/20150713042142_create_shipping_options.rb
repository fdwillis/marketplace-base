class CreateShippingOptions < ActiveRecord::Migration
  def change
    create_table :shipping_options do |t|
      t.decimal :price, precision: 12, scale: 2
      t.string :title
      t.belongs_to :product, index: true

      t.timestamps null: false
    end
    add_foreign_key :shipping_options, :products
  end
end
