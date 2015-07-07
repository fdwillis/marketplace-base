class AddMarketplaceStripeIdToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :marketplace_stripe_id, :string
  end
end
