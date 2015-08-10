class AddOrderUuidToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :order_uuid, :string
  end
end
