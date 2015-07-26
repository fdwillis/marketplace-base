class AddDescriptionToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :description, :string
  end
end
