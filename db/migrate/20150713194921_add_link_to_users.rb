class AddLinkToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bitly_link, :string
  end
end
