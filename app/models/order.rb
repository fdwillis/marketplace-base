class Order < ActiveRecord::Base
  belongs_to :user
  after_update :total_price

  has_many :order_items, dependent: :destroy
  has_many :users, through: :order_items
  
  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true

  def total_price
    self.total_price = ((order_items.map(&:price).sum + shipping_price) + ((order_items.map(&:price).sum + shipping_price) * User.find(merchant_id).tax_rate / 100  ))
  end
end
