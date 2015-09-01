class AddUuidToTeamMembers < ActiveRecord::Migration
  def change
    add_column :team_members, :uuid, :string
  end
end
