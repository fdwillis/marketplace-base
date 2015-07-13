class Product < ActiveRecord::Base

  extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  belongs_to :user

  has_many :purchases
  has_many :shipping_options
  has_many :users, through: :purchases

  validates_uniqueness_of :title
  validates :price, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: {greater_than: 0}

  mount_uploader :product_image, PhotoUploader

  accepts_nested_attributes_for :shipping_options, reject_if: :all_blank, allow_destroy: true

  def total_price
    (price * 100) + (price * user.tax_rate) #+ chosen shipping_address
  end
end
