class AddDobToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dob_day, :integer
    add_column :users, :dob_month, :integer
    add_column :users, :dob_year, :integer
  end
end
