class AddMarketplaceStripeIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :marketplace_stripe_id, :string
  end
end
