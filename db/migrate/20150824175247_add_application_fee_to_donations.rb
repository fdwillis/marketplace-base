class AddApplicationFeeToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :application_fee, :decimal, precision: 12, scale: 2
  end
end
