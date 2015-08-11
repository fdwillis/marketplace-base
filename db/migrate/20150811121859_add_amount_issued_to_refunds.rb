class AddAmountIssuedToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :amount_issued, :decimal, default: 0.0
  end
end
