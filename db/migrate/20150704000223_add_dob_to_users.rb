class AddDobToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dob_day, :string
    add_column :users, :dob_month, :string
    add_column :users, :dob_year, :string
  end
end
