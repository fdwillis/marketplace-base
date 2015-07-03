class AddAttachmentProductImageToPurchases < ActiveRecord::Migration
  def self.up
    change_table :purchases do |t|
      t.attachment :product_image
    end
  end

  def self.down
    remove_attachment :purchases, :product_image
  end
end
