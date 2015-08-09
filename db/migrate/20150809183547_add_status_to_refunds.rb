class AddStatusToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :status, :string
  end
end
