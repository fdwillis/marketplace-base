class AddReturnPolicyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :return_policy, :text
  end
end
