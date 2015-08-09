class CreateRefunds < ActiveRecord::Migration
  def change
    create_table :refunds do |t|
      t.belongs_to :order, index: true
      t.string :amount
      t.string :note

      t.timestamps null: false
    end
    add_foreign_key :refunds, :orders
  end
end
