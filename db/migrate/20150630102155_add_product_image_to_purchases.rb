class AddProductImageToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :product_image, :string
  end
end
