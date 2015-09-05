class FundraisingGoal < ActiveRecord::Base

  before_save :set_keywords

	has_many :donations

	extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  mount_uploader :goal_image, PhotoUploader

  acts_as_taggable

  belongs_to :user
  
  validates :goal_amount, numericality: {greater_than_or_equal_to: 0}
  validates_uniqueness_of :title

  def tag_list
    tags.map(&:name).join(", ")
  end
protected
  def set_keywords
    self.keywords = [description, title, user.username, "#{ActionController::Base.helpers.number_to_currency(goal_amount, precision: 2)}"].join(", ")
  end
end
