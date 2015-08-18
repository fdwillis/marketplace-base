class AddUuidToFundraisingGoals < ActiveRecord::Migration
  def change
    add_column :fundraising_goals, :uuid, :string
  end
end
