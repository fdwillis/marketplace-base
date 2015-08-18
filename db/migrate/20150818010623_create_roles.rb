class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.belongs_to :user, index: true
      t.string :title

      t.timestamps null: false
    end
    add_foreign_key :roles, :users
  end
end
