class Product < ActiveRecord::Base

  # has_attached_file :product_image, styles: { medium: "350x350#", thumb: "100x100>#" }, default_url: "https://cdn3.iconfinder.com/data/icons/abstract-1/512/no_image-512.png"
  # validates_attachment_content_type :product_image, { :content_type => ["image/jpeg", "image/gif", "image/png"] }

  extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  belongs_to :user

  has_many :purchases
  has_many :users, through: :purchases

  validates_uniqueness_of :title
  validates :price, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: {greater_than: 0}

  mount_uploader :product_image, PhotoUploader
end
