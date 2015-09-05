class AddGoalImageToFundraisingGoals < ActiveRecord::Migration
  def change
    add_column :fundraising_goals, :goal_image, :string
  end
end
