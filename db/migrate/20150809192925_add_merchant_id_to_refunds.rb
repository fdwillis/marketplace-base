class AddMerchantIdToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :merchant_id, :integer
  end
end
