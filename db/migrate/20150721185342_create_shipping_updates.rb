class CreateShippingUpdates < ActiveRecord::Migration
  def change
    create_table :shipping_updates do |t|
      t.string :message
      t.string :checkpoint_time
      t.string :tag
      t.belongs_to :purchase

      t.timestamps null: false
    end
  end
end
