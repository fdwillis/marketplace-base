class AddApplicationFeeToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :application_fee, :string
  end
end
