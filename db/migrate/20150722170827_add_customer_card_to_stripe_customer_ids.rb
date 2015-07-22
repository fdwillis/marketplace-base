class AddCustomerCardToStripeCustomerIds < ActiveRecord::Migration
  def change
    add_column :stripe_customer_ids, :customer_card, :string
  end
end
