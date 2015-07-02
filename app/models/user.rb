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
    if card_number
      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      @card = @crypt.decrypt_and_verify(card_number)
    end
    (@card.present? || card_number.present?) && exp_year.present? && exp_month.present? && cvc_number.present?
  end

  def recipient?
    tax_id.present? && routing_number.present? && account_number.present? && legal_name.present?
  end

  def self.charge_n_create(price, stripe_id)

    @price = price
    @fee = (@price * (350) / 100) / 100
    @merchant60 = ((@price) * 60) /100
    @admin40 = (@price - @merchant60)

    @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
    @card = @crypt.decrypt_and_verify(card_number)

    customer = Stripe::Customer.create(
      email: email,
      source: {
        object: 'card',
        number: @card,
        exp_month: exp_month,
        exp_year: exp_year,
        cvc: cvc_number,
      },
    )

    update_attributes(stripe_id: customer.id)
    save!

    charge = Stripe::Charge.create(
      customer:    stripe_id,
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