class CreateFundraisingGoals < ActiveRecord::Migration
  def change
    create_table :fundraising_goals do |t|
      t.string :title
      t.text :description
      t.belongs_to :user, index: true
      t.decimal :goal_amount, precision: 12, scale: 2
      t.integer :backers

      t.timestamps null: false
    end
    add_foreign_key :fundraising_goals, :users
  end
end
