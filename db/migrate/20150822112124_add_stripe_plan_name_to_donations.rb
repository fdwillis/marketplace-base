class AddStripePlanNameToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :stripe_plan_name, :string
  end
end
