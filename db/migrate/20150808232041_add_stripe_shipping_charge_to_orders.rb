class AddStripeShippingChargeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :stripe_shipping_charge, :string
  end
end
