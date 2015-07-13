class AddTaxRateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tax_rate, :decimal, precision: 12, scale: 2
  end
end
