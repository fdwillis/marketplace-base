class AddAmountIssuedToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :amount_issued, :decimal, precision: 12, scale: 2, default: 0.0
  end
end
