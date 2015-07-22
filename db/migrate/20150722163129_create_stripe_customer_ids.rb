class CreateStripeCustomerIds < ActiveRecord::Migration
  def change
    create_table :stripe_customer_ids do |t|
      t.belongs_to :user, index: true
      t.string :business_name
      t.string :customer_id

      t.timestamps null: false
    end
    add_foreign_key :stripe_customer_ids, :users
  end
end
