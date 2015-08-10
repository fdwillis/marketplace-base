class CreateReturnedProducts < ActiveRecord::Migration
  def change
    create_table :returned_products do |t|
      t.string :title
      t.string :price
      t.string :uuid
      t.belongs_to :refund, index: true

      t.timestamps null: false
    end
    add_foreign_key :returned_products, :refunds
  end
end
