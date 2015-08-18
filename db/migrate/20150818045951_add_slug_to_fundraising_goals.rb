class AddSlugToFundraisingGoals < ActiveRecord::Migration
  def change
    add_column :fundraising_goals, :slug, :string
    add_index :fundraising_goals, :slug, unique: true
  end
end
