class AddAttachmentProductImageToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :product_image, :string
  end

  def self.down
    remove_column :products, :product_image
  end
end
