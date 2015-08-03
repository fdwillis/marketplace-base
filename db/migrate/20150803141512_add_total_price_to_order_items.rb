class AddTotalPriceToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :total_price, :decimal
  end
end
