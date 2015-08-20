class FundraisingGoal < ActiveRecord::Base
	has_many :donations

	extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  acts_as_taggable

  belongs_to :user
  
  validates :goal_amount, numericality: {greater_than_or_equal_to: 0}
  validates_uniqueness_of :title

  def tag_list
    tags.map(&:name).join(", ")
  end
end
