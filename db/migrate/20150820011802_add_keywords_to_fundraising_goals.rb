class AddKeywordsToFundraisingGoals < ActiveRecord::Migration
  def change
    add_column :fundraising_goals, :keywords, :text
  end
end
