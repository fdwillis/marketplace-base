class AddProductTagsToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :product_tags, :string
  end
end
