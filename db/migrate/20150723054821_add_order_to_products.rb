class AddOrderToProducts < ActiveRecord::Migration
  def change
    add_reference :products, :order, index: true
    add_foreign_key :products, :orders
  end
end
