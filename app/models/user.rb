class User < ActiveRecord::Base
  before_save :phone_number
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  extend FriendlyId
  friendly_id :username, use: [:slugged, :finders]
  
  has_many :orders, dependent: :destroy
  has_many :products
  
  has_many :purchases
  has_many :roles
  has_many :transfers
  has_many :shipping_addresses
  has_many :stripe_customer_ids
  has_many :fundraising_goals

  validates_uniqueness_of :business_name, :username

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates_numericality_of :exp_year, greater_than_or_equal_to: Time.now.year, allow_blank: true
  validates_numericality_of :dob_year, :dob_month, :dob_day, :exp_month, :cvc_number, allow_blank: true

  accepts_nested_attributes_for :shipping_addresses, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :stripe_customer_ids, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :orders, reject_if: :all_blank, allow_destroy: true

  def admin?
    role == "admin"
  end

  def merchant?
    role == 'merchant'
  end

  def fundraiser?
    role == 'fundraiser'
  end

  def phone_number
    if support_phone
      write_attribute(:support_phone, support_phone.gsub(/\D/, ''))
    end
  end

  def buyer?
    role == 'buyer'
  end

  def card?
    @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
    if card_number
      @card = @crypt.decrypt_and_verify(card_number)
    end
    (@card.present? || card_number.present?) && exp_year.present? && support_phone.present? && exp_month.present? && cvc_number.present? && currency.present? && (legal_name.present? || first_name.present && last_name.present?)
  end

  def user_recipient
    puts "Current Information for Bank Account Transfers:\n 
    SSN: #{tax_id.present?} \n Routing Number #{routing_number.present?} \n Legal Name: #{legal_name.present?} \n Account Number: #{account_number.present?}"
  end

  def shipping_to
    shipping_addresses.map{|f| [f.street.upcase, f.city.upcase, f.state.upcase, f.region.upcase, f.zip].join(", ")}
  end

  def basic_biz_info?
    tax_rate.present? && return_policy.present? && address_city.present? && address_state.present? && address_zip.present? && address.present? && address_country.present? && statement_descriptor.present? && business_name.present? && business_url.present? && support_email.present? && support_phone.present? && support_url.present? && first_name.present? && last_name.present? && dob_day.present? && dob_month.present? && dob_year.present?
  end

  def merchant_bank_account?
    bank_currency.present? && routing_number.present? && account_number.present? && stripe_account_type.present?
  end

  def merchant_ready?
    card?.present? && merchant_bank_account?.present?
  end

  def merchant_changed
    routing_number_changed? || account_number_changed? || stripe_account_type_changed?
  end

  def stripe_account_id_ready?
    stripe_account_id.present?
  end

  def self.charge_n_process(secret_key, user, price, token, merchant_account_id, currency)
    debugger

    @token = token.id
    @price = price
    @merchant60 = ((@price) * 60) /100
    @fee = (@price - @merchant60)

    @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
    @merchant_secret = @crypt.decrypt_and_verify(secret_key)
    Stripe.api_key = @merchant_secret

    @customers = Stripe::Customer.all.data
    @customer_ids = @customers.map(&:id)
    @customer_account = user.stripe_customer_ids.where(business_name: Stripe::Account.retrieve().business_name).first
  
    if !@customer_account.nil? && @customer_account.present?
      customer_card = @customer_account.customer_card
      charge = Stripe::Charge.create(
      {
        amount: @price,
        currency: 'USD',
        customer: @customer_account.customer_id ,
        description: 'MarketplaceBase',
        application_fee: @fee,
      },
      {stripe_account: merchant_account_id}
        )  
    else
      
      @customer = Stripe::Customer.create(
        :description => "Customer For MarketplaceBase",
        :source => @token
      )
    
      user.stripe_customer_ids.create(business_name: Stripe::Account.retrieve().business_name, 
                                      customer_card: @customer.default_source, customer_id: @customer.id)
      
      charge = Stripe::Charge.create(
        {
          amount: @price,
          currency: 'USD',
          customer: @customer.id,
          description: 'MarketplaceBase',
          application_fee: @fee,
          
        },
        {stripe_account: merchant_account_id}
        )
      debugger
    end
  end

  def self.charge_for_admin(user, price, token)
    @customers = Stripe::Customer.all.data
    @customer_ids = @customers.map(&:id)
    @customer_account = user.stripe_customer_ids.where(business_name: Stripe::Account.retrieve().business_name).first

    if !@customer_account.nil? && @customer_account.present?
      
      customer_card = @customer_account.customer_card
      charge = Stripe::Charge.create(
        amount: price,
        currency: 'USD',
        customer: @customer_account.customer_id ,
        description: 'MarketplaceBase',
      )  
    else
      @customer = Stripe::Customer.create(
        :description => "Customer For MarketplaceBase",
        :source => token
      )
    
      user.stripe_customer_ids.create(business_name: Stripe::Account.retrieve().business_name, 
                                      customer_card: @customer.default_source, customer_id: @customer.id)

      charge = Stripe::Charge.create(
        amount: price,
        currency: 'USD',
        customer: @customer.id,
        description: 'MarketplaceBase',
      )
    end
  end

  def self.new_token(current_user, card)
    Stripe::Token.create(
      card: {
        number: card,
        exp_month: current_user.exp_month,
        exp_year: current_user.exp_year,
        cvc: current_user.cvc_number,
        name: current_user.legal_name,
        address_city: current_user.address_city,
        address_zip: current_user.address_zip,
        address_state: current_user.address_state,
        address_country: current_user.country_name,
      },
    )
  end
end







