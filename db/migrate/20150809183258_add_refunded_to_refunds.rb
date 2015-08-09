class AddRefundedToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :refunded, :boolean
  end
end
