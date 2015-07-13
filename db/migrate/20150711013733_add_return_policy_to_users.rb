class AddReturnPolicyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :return_policy, :text, default: 'Our policy lasts 30 days. If 30 days have gone by since your purchase, unfortunately we can’t offer you a refund or exchange.

To be eligible for a return, your item must be unused and in the same condition that you received it. It must also be in the original packaging.'
  end
end
