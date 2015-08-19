class CreateDonationPlans < ActiveRecord::Migration
  def change
    create_table :donation_plans do |t|
      t.decimal :amount, precision: 12, scale: 2
      t.string :interval
      t.string :name
      t.string :currency, default: 'usd'
      t.string :uuid
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :donation_plans, :users
  end
end
