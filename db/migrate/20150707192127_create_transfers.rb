class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.string :status
      t.integer :amount
      t.string :date_created
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :transfers, :users
  end
end
