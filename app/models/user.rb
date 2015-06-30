class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  has_many :products
  has_many :purchases

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates_length_of :exp_month, maximum: 2
  validates_length_of :exp_year, maximum: 4

  def admin?
    role == "admin"
  end

  def merchant?
    role == 'merchant'
  end

  def buyer?
    role == 'buyer'
  end

  def card?
    card_number.present? && exp_year.present? && exp_month.present? && cvc_number.present?
  end

  def recipient?
    tax_id.present? && routing_number.present? && account_number.present? && legal_name.present?
  end

end