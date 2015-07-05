class AddMerchantLast4ToUsers < ActiveRecord::Migration
  def change
    add_column :users, :merchant_last_4, :string
  end
end
