class Purchase < ActiveRecord::Base
  has_attached_file :product_image, styles: { medium: "350x350#", thumb: "100x100>#" }, default_url: "https://cdn3.iconfinder.com/data/icons/abstract-1/512/no_image-512.png"
  validates_attachment_content_type :product_image, { :content_type => ["image/jpeg", "image/gif", "image/png"] }

  belongs_to :user

  has_many :products
  has_many :users, through: :products
end
