class AddNoteToReturnedProducts < ActiveRecord::Migration
  def change
    add_column :returned_products, :note, :string
  end
end
