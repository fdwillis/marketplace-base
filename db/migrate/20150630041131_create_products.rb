class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title
      t.decimal :price, precision: 12, scale: 2
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :products, :users
  end
end
