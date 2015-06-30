class Purchase < ActiveRecord::Base
  belongs_to :user, dependent: :destroy

  has_many :products
  has_many :users, through: :products
end
