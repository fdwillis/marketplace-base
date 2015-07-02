class Product < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :user

  has_many :purchases
  has_many :users, through: :purchases

  validates_uniqueness_of :title
end
