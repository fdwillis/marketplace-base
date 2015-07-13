class Product < ActiveRecord::Base

  extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  belongs_to :user

  has_many :purchases
  has_many :users, through: :purchases

  validates_uniqueness_of :title
  validates :price, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: {greater_than: 0}

  mount_uploader :product_image, PhotoUploader
end
