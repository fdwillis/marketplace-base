class Order < ActiveRecord::Base
  belongs_to :user

  has_many :order_items, dependent: :destroy
  has_many :users, through: :order_items
  
  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true

  def product_price
    self.total_price = order_items.map(&:price).sum
  end
end
