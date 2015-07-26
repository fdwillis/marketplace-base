class Order < ActiveRecord::Base
  belongs_to :user

  has_many :order_items, dependent: :destroy
  has_many :users, through: :order_items
  
  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true

  def product_price
    self.total_price = order_items.map(&:price).sum
  end
  def total_price
    (product_price + shipping_price) + ((product_price + shipping_price) * User.find(merchant_id).tax_rate / 100 )
  end
  def self.product_price(order)
    total_price = order.order_items.map(&:price).sum
  end
end
