class Order < ActiveRecord::Base
  belongs_to :user

  has_many :products, dependent: :destroy
  has_many :users, through: :products
  
  accepts_nested_attributes_for :products, reject_if: :all_blank, allow_destroy: true

  def self.product_price(price)
    debugger
    total_price += price
  end
end
