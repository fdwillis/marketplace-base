class ShippingAddress < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :street, :city, :state, :region, :zip
  validates :zip, numericality: {greater_than: 0}
end
