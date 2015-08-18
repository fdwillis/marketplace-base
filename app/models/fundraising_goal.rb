class FundraisingGoal < ActiveRecord::Base
	extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  belongs_to :user
  
  validates :goal_amount, numericality: {greater_than_or_equal_to: 0}
  validates_uniqueness_of :title
end
