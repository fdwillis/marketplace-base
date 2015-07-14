class AddBankCurrencyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bank_currency, :string
  end
end
