class AddStripeSubscriptionIdToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :stripe_subscription_id, :string
  end
end
