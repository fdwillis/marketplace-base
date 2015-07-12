class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title
      t.decimal :price
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :products, :users
  end
end
