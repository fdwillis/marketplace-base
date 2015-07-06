class AddBooleansToProducts < ActiveRecord::Migration
  def change
    add_column :products, :pending, :boolean
  end
end
