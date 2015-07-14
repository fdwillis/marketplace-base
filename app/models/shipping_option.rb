class ShippingOption < ActiveRecord::Base
  belongs_to :product
  validates :price, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: {greater_than: 0}
end
