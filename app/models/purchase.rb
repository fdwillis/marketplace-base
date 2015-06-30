class Purchase < ActiveRecord::Base
  belongs_to :user

  has_many :products
  has_many :users, through: :products
  
end
