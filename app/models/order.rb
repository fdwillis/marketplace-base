class Order < ActiveRecord::Base
  belongs_to :user
  after_update :total_price

  has_many :shipping_updates, dependent: :destroy
  has_many :refunds, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :users, through: :order_items
  
  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :shipping_updates, reject_if: :all_blank, allow_destroy: true

  def self.shipping_price(order)
    @oi_shipping_price = order.order_items.map(&:shipping_price)
    @oi_max = @oi_shipping_price.max

    @total_shipp = []
    order.order_items.each do |oi|
      @total_shipp << oi.shipping_price * oi.quantity
    end
    shipping_price = (@oi_max + ((@total_shipp.sum - @oi_max ) * 0.65 ) ).round(2)
  end
  def self.total_price(order)
    @prod_shipp = order.order_items.map(&:total_price).sum + self.shipping_price(order)
    total_price = ((@prod_shipp.to_f.round(2)) + ((@prod_shipp.to_f.round(2)) * User.find(order.merchant_id).tax_rate / 100  ))
  end
end
