class AddTagsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :product_tags, :text
  end
end
