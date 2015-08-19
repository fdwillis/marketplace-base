class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.string :organization
      t.decimal :amount, precision: 12, scale: 2
      t.string :uuid
      t.string :fundraising_goal
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :donations, :users
  end
end
