class Order < ActiveRecord::Base
  belongs_to :user
  after_update :total_price

  has_many :shipping_updates
  has_many :order_items, dependent: :destroy
  has_many :users, through: :order_items
  
  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :shipping_updates, reject_if: :all_blank, allow_destroy: true

  def self.shipping_price(order)
    @oi_shipping_price = order.order_items.map(&:shipping_price)
    @oi_max = @oi_shipping_price.max
    shipping_price = (@oi_max + ((@oi_shipping_price.sum - @oi_max ) * 0.65 ) )
  end
  def self.total_price(order)
    @prod_shipp = order.order_items.map(&:price).sum + order.shipping_price
    total_price = ((@prod_shipp) + ((@prod_shipp) * User.find(order.merchant_id).tax_rate / 100  ))
  end
end
