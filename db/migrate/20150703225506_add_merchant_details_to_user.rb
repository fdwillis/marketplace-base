class AddMerchantDetailsToUser < ActiveRecord::Migration
  def change
    add_column :users, :merchant_id, :string
    add_column :users, :business_name, :string
    add_column :users, :business_url, :string
    add_column :users, :support_email, :string
    add_column :users, :support_phone, :string
    add_column :users, :support_url, :string
    add_column :users, :statement_descriptor, :string
  end
end
