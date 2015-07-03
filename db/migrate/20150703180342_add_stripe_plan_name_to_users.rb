class AddStripePlanNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_plan_name, :string
  end
end
