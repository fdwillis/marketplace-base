class AddTaxRateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tax_rate, :decimal, precision: 12, scale: 3
  end
end
