class AddUuidToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :uuid, :string
  end
end
