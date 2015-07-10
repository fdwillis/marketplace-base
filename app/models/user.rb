class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  extend FriendlyId
  friendly_id :username, use: [:slugged, :finders]
  
  has_many :products
  has_many :purchases
  has_many :transfers

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates_numericality_of :exp_year, greater_than_or_equal_to: Time.now.year, allow_blank: true
  validates_numericality_of :dob_year, :dob_month, :dob_day, :exp_month, :cvc_number, allow_blank: true


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
    @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
    if card_number
      @card = @crypt.decrypt_and_verify(card_number)
    end
    (@card.present? || card_number.present?) && exp_year.present? && exp_month.present? && cvc_number.present? && currency.present? && address_city.present? && address_zip.present? && address_country.present? && legal_name.present?
  end

  def user_recipient
    puts "Current Information for Bank Account Transfers:\n 
    SSN: #{tax_id.present?} \n Routing Number #{routing_number.present?} \n Legal Name: #{legal_name.present?} \n Account Number: #{account_number.present?}"
  end

  def merchant_ready?
    address_city.present? && address_state.present? && address_zip.present? && address.present? && currency.present? && address_country.present? && statement_descriptor.present? && routing_number.present? && account_number.present? && business_name.present? && business_url.present? && support_email.present? && support_phone.present? && support_url.present? && first_name.present? && last_name.present? && dob_day.present?&& dob_month.present? && dob_year.present? && stripe_account_type.present?
  end

  def merchant_changed
    routing_number_changed? || account_number_changed? || stripe_account_type_changed?
  end

  def stripe_account_id_ready?
    stripe_account_id.present?
  end

  def self.charge_n_process(price, token, stripe_account_id, currency )
    @price = price
    @merchant60 = ((@price) * 60) /100
    @fee = (@price - @merchant60)

    charge = Stripe::Charge.create(
    {
      amount:      @price,
      currency:    currency,
      source: token.id ,
      description: 'MarketplaceBase',
      application_fee: @fee,
    },
    {stripe_account: stripe_account_id}
    )  
  end

  def self.charge_for_admin(price, token)
    Stripe::Charge.create(
      amount: price,
      currency: "usd",
      source: token, 
      description: "MarketplaceBase",
    )
  end
end







