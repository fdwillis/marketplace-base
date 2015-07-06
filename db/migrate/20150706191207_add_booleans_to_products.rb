class AddBooleansToProducts < ActiveRecord::Migration
  def change
    add_column :products, :showcase, :boolean
    add_column :products, :pending, :boolean
    add_column :products, :published, :boolean
  end
end
