class AddRecipientCreatedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :recipient_created, :boolean
  end
end
