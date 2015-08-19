class Donation < ActiveRecord::Base
  belongs_to :user
  belongs_to :fundraising_goal
end
