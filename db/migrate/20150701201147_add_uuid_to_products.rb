class AddUuidToProducts < ActiveRecord::Migration
  def change
    add_column :purchases, :uuid, :string
    add_column :products, :uuid, :string
  end
end
