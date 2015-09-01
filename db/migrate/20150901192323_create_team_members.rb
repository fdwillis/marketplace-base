class CreateTeamMembers < ActiveRecord::Migration
  def change
    create_table :team_members do |t|
      t.string :name
      t.decimal :percent, precision: 12, scale: 2
      t.string :stripe_bank_id
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :team_members, :users
  end
end
