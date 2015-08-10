class Refund < ActiveRecord::Base
  belongs_to :order
  has_many :returned_products, dependent: :destroy

  accepts_nested_attributes_for :returned_products, reject_if: :all_blank, allow_destroy: true

  validates_numericality_of :amount, greater_than_or_equal_to: 0, presence: true
end
