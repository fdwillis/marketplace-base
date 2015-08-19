class AddActiveToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :active, :boolean
  end
end
