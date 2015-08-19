class AddFundraiserStripeAccountIdToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :fundraiser_stripe_account_id, :string
  end
end
