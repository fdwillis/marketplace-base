class AddApplicationFeeToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :application_fee, :string
  end
end
