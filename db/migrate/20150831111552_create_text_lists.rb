class CreateTextLists < ActiveRecord::Migration
  def change
    create_table :text_lists do |t|
      t.string :phone_number
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :text_lists, :users
  end
end
