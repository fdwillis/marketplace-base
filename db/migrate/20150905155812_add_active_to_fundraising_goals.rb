class AddActiveToFundraisingGoals < ActiveRecord::Migration
  def change
    add_column :fundraising_goals, :active, :boolean
  end
end
