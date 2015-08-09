class Refund < ActiveRecord::Base
  belongs_to :order
  validates_numericality_of :amount, greater_than_or_equal_to: 0, presence: true
end
