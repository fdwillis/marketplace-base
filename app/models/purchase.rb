class Purchase < ActiveRecord::Base

  belongs_to :user

  has_many :products
  has_many :users, through: :products
  has_many :shipping_updates

  def self.new_product(uuid, merchant_id, stripe_charge_id, title, price, user_id, product_id, application_fee, purchase_id, status, shipping_option, ship_to, quantity)
    self.create(uuid: uuid, merchant_id: merchant_id, stripe_charge_id: stripe_charge_id, 
                title: title, price: price, user_id: user_id, product_id: product_id, 
                application_fee: application_fee, purchase_id: purchase_id, status: status, 
                shipping_option: shipping_option, ship_to: ship_to, quantity: quantity)
  end

  def self.update_quantity(new_q, product)
    if new_q == 0
      product.update_attributes(status: "Sold Out")
    end
    product.update_attributes(quantity: new_q)
  end
end
