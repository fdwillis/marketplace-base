class AddDonationTypeToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :donation_type, :string
  end
end
