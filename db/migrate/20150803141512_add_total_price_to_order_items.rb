class AddTotalPriceToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :total_price, :decimal, precision: 12, scale: 2
  end
end
