class Product < ActiveRecord::Base
  belongs_to :user

  has_many :purchases
  has_many :users, through: :purchases

  validates_uniqueness_of :title
end
