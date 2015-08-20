class AddStripeSubscriptionIdToDonationPlans < ActiveRecord::Migration
  def change
    add_column :donation_plans, :stripe_subscription_id, :string
  end
end
