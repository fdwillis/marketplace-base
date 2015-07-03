class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  extend FriendlyId
  friendly_id :username, use: [:slugged, :finders]
  
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
    if card_number
      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      @card = @crypt.decrypt_and_verify(card_number)
    end
    (@card.present? || card_number.present?) && exp_year.present? && exp_month.present? && cvc_number.present?
  end

  def user_recipient
    puts "Current Information for Bank Account Transfers:\n 
    SSN: #{tax_id.present?} \n Routing Number #{routing_number.present?} \n Legal Name: #{legal_name.present?} \n Account Number: #{account_number.present?}"
  end

  def recipient?
    tax_id.present? && routing_number.present? && account_number.present? && legal_name.present?
  end

  def self.charge_n_create(price, stripe_id, user)

    @price = price
    @fee = (@price * (350) / 100) / 100
    @merchant60 = ((@price) * 60) /100
    @admin40 = (@price - @merchant60)

    @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
    @card = @crypt.decrypt_and_verify(user.card_number)

    customer = Stripe::Customer.create(
      email: user.email,
      source: {
        object: 'card',
        number: @card,
        exp_month: user.exp_month,
        exp_year: user.exp_year,
        cvc: user.cvc_number,
      },
    )

    @user = user.update_attributes(stripe_id: customer.id)

    charge = Stripe::Charge.create(
      customer:    customer.id,
      amount:      @price + @fee,
      description: 'Rails Stripe customer',
      currency:    'usd'
    )
  end

  def self.charge_n_process(price, stripe_id)

    @price = price
    @fee = (@price * (350) / 100) / 100
    @merchant60 = ((@price) * 60) /100
    @admin40 = (@price - @merchant60)

    Stripe::Charge.create(
      customer:    stripe_id,
      amount:      @price + @fee,
      description: 'Rails Stripe customer',
      currency:    'usd'

    )
  end
end