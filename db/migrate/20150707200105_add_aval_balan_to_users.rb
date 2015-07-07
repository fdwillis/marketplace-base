class AddAvalBalanToUsers < ActiveRecord::Migration
  def change
    add_column :users, :available_balance, :integer
  end
end
