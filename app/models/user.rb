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

  def merchant_ready?
    statement_descriptor.present? && tax_id.present? && routing_number.present? && account_number.present? && business_name.present? && business_url.present? && support_email.present? && support_phone.present? && support_url.present? && first_name.present? && last_name.present? && dob_day.present?&& dob_month.present? && dob_year.present? && stripe_account_type.present?
  end

  def self.charge_n_create(price, token, stripe_account_id, email, user)

    @price = price
    @merchant60 = ((@price) * 60) /100
    @fee = (@price - @merchant60)

    @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

    customer = Stripe::Customer.create(
      {
        email: email,
        card: token.id,
      },
      {stripe_account: stripe_account_id}
    )

    @user = user.update_attributes(stripe_id: token.id)

    charge = Stripe::Charge.create(
      {
        customer:    customer.id,
        amount:      @price,
        description: 'MarketplaceBase',
        currency:    'usd',
        application_fee: @fee,
      },
      {stripe_account: stripe_account_id}
    )
  end

  def self.charge_n_process(price, stripe_id, stripe_account_id, email)

    @price = price
    @fee = (@price * (350) / 100) / 100
    @merchant60 = ((@price) * 60) /100
    @admin40 = (@price - @merchant60)

    charge = Stripe::Charge.create(
    {
      source:    stripe_id,
      amount:      @price,
      description: 'MarketplaceBase',
      currency:    'usd',
      application_fee: @fee,
    },
    {stripe_account: stripe_account_id}

    )
  end
end