class AddBankDeetsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tax_id, :string
    add_column :users, :routing_number, :string
    add_column :users, :account_number, :string
    add_column :users, :stripe_recipient_id, :string
  end
end
