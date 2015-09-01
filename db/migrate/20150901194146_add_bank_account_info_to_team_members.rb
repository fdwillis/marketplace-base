class AddBankAccountInfoToTeamMembers < ActiveRecord::Migration
  def change
    add_column :team_members, :routing_number, :string
    add_column :team_members, :country, :string
    add_column :team_members, :account_number, :string
  end
end
