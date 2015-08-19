class AddFundraisingGoalIdToDonations < ActiveRecord::Migration
  def change
    add_reference :donations, :fundraising_goal, index: true
    add_foreign_key :donations, :fundraising_goals
  end
end
