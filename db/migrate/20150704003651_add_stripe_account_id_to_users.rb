class AddStripeAccountIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_account_id, :string
  end
end
