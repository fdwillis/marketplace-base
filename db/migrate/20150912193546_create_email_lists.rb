class CreateEmailLists < ActiveRecord::Migration
  def change
    create_table :email_lists do |t|
      t.string :email
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :email_lists, :users
  end
end
