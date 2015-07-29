class AddUuidToShippingOptions < ActiveRecord::Migration
  def change
    add_column :shipping_options, :uuid, :string
  end
end
