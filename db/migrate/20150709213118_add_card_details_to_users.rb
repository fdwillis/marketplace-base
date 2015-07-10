class AddCardDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :address_city, :string
    add_column :users, :address_zip, :string
    add_column :users, :address_state, :string
    add_column :users, :address_country, :string
  end
end
