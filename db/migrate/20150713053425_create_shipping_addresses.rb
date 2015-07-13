class CreateShippingAddresses < ActiveRecord::Migration
  def change
    create_table :shipping_addresses do |t|
      t.string :street
      t.string :city
      t.string :state
      t.string :region
      t.string :zip
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :shipping_addresses, :users
  end
end
