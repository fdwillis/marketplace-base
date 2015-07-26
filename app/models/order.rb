class Order < ActiveRecord::Base
  belongs_to :user

  has_many :order_items, dependent: :destroy
  has_many :users, through: :order_items
  
  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true

  def self.product_price(price)
    total_price = total_price.to_i + price
  end
end
