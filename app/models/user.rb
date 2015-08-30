class User < ActiveRecord::Base
  before_save :phone_number
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  extend FriendlyId
  friendly_id :username, use: [:slugged, :finders]
  
  has_many :orders, dependent: :destroy
  has_many :products
  
  has_many :purchases
  has_many :donation_plans
  has_many :roles
  has_many :donations
  has_many :transfers
  has_many :shipping_addresses
  has_many :stripe_customer_ids
  has_many :fundraising_goals

  validates_uniqueness_of :business_name, :username

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable#, :confirmable

  validates_numericality_of :exp_year, greater_than_or_equal_to: Time.now.year, allow_blank: true
  validates_numericality_of :dob_year, :dob_month, :dob_day, :exp_month, :cvc_number, allow_blank: true

  accepts_nested_attributes_for :donation_plans, reject_if: :all_blank, allow_destroy: true
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

  protected

    def self.profile_views(user_id, ip_address, location, merchant)
      Keen.publish("Profile Views", {
        marketplace_name: "MarketplaceBase",
        platform_for: 'apparel', 
        ip_address: ip_address, 
        customer_id: user_id,
        profile_viewed: merchant.id,
        customer_current_zipcode: location["zipcode"],
        customer_current_city: location["city"] ,
        customer_current_state: location["region_name"],
        customer_current_country: location["country_name"],
        year: Time.now.strftime("%Y").to_i,
        month: DateTime.now.to_date.strftime("%B"),
        day: Time.now.strftime("%d").to_i,
        day_of_week: DateTime.now.to_date.strftime("%A"),
        hour: Time.now.strftime("%H").to_i,
        minute: Time.now.strftime("%M").to_i,
        timestamp: Time.now,
      })
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

    def self.new_customer(token, user)
      #Keen event "New Paying Customers"
      customer = Stripe::Customer.create(
          :description => "Customer For MarketplaceBase",
          :source => token
        )
      user.stripe_customer_ids.create(business_name: Stripe::Account.retrieve().business_name, 
                                      customer_card: customer.default_source, customer_id: customer.id)
    end

    def self.decrypt_and_verify(secret_key)
      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      @merchant_secret = @crypt.decrypt_and_verify(secret_key)
      Stripe.api_key = @merchant_secret
    end

    def self.find_stripe_customer_id(user)
      
      @customers = Stripe::Customer.all.data
      @customer_ids = @customers.map(&:id)
      @customer_account = user.stripe_customer_ids.where(business_name: Stripe::Account.retrieve().business_name).first
    end

    def self.charge_n_process(secret_key, user, price, token, merchant_account_id)
      @price = price
      @merchant60 = ((price) * 60) /100
      @fee = (@price - @merchant60)
      # Call to create token here
      User.decrypt_and_verify(secret_key)
      User.find_stripe_customer_id(user)
      
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
        
        @customer = User.new_customer(token, user)
        
        charge = Stripe::Charge.create(
          {
            amount: @price,
            currency: 'USD',
            customer: @customer.customer_id,
            description: 'MarketplaceBase',
            application_fee: @fee,
            
          },
          {stripe_account: merchant_account_id}
          )
      end
    end

    def self.charge_for_admin(user, price, token)
      # Call to create token here
      
      User.find_stripe_customer_id(user)

      if !@customer_account.nil? && @customer_account.present?
        customer_card = @customer_account.customer_card
        charge = Stripe::Charge.create(
          amount: price,
          currency: 'USD',
          customer: @customer_account.customer_id ,
          description: 'MarketplaceBase',
        )  
      else
        @customer = User.new_customer(token, user)

        charge = Stripe::Charge.create(
          amount: price,
          currency: 'USD',
          customer: @customer.customer_id,
          description: 'MarketplaceBase',
        )
      end
    end

    def self.subscribe_to_fundraiser(secret_key, user, token, merchant_account_id, donation_plan)

      User.decrypt_and_verify(secret_key)
      User.find_stripe_customer_id(user)

      if !@customer_account.nil? && @customer_account.present?
        customer_card = @customer_account.customer_card
      else
        @customer_account = User.new_customer(token, user)
      end

      customer = Stripe::Customer.retrieve(@customer_account.customer_id)
      plan = customer.subscriptions.create(:plan => donation_plan, application_fee_percent: 40)
    end

    def self.subscribe_to_admin(user, token, donation_plan)

      User.find_stripe_customer_id(user)

      if !@customer_account.nil? && @customer_account.present?
        customer_card = @customer_account.customer_card
      else
        @customer_account = User.new_customer(token, user)
      end

      customer = Stripe::Customer.retrieve(@customer_account.customer_id)
      plan = customer.subscriptions.create(:plan => donation_plan)
    end

    def self.create_merchant(user, ip_address, user_agent)
      merchant = Stripe::Account.create(
        managed: true,
        country: user.address_country,
        email: user.email,
        business_url: user.business_url,
        business_name: user.business_name,
        support_url: user.support_url,
        support_phone: user.support_phone,
        support_email: user.support_email,
        debit_negative_balances: true,
        external_account: {
          object: 'bank_account',
          country: user.address_country,
          currency: user.currency,
          routing_number: user.routing_number,
          account_number: @crypt.decrypt_and_verify(user.account_number),
        },
        tos_acceptance: {
          ip: ip_address,
          date: Time.now.to_i,
          user_agent: user_agent,
        },
        legal_entity: {
          type: user.stripe_account_type,
          business_name: user.business_name,
          first_name: user.first_name,
          last_name: user.last_name,
          dob: {
            day: user.dob_day,
            month: user.dob_month,
            year: user.dob_year,
          },
          address: {
            line1: user.address,
            city: user.address_city,
            state: user.address_state,
            postal_code: user.address_zip,
            country: user.address_country,
          }
        },
        decline_charge_on: {
          cvc_failure: true,
        },
        transfer_schedule:{
          interval: 'manual',
        },
      )
    end

    def self.new_paying_merchant(location, ip_address, price, user)
      Keen.publish("New Paying Merchant", {
        marketplace_name: "MarketplaceBase",
        platform_for: 'apparel', 
        ip_address: ip_address, 
        customer_current_zipcode: location["zipcode"],
        customer_current_city: location["city"] ,
        customer_current_state: location["region_name"],
        customer_current_country: location["country_name"],
        year: Time.now.strftime("%Y").to_i,
        month: DateTime.now.to_date.strftime("%B"),
        day: Time.now.strftime("%d").to_i,
        day_of_week: DateTime.now.to_date.strftime("%A"),
        hour: Time.now.strftime("%H").to_i,
        minute: Time.now.strftime("%M").to_i,
        subscription_price: (price/100).to_f, 
        merchant_email: user.email,
        sign_in_count: user.sign_in_count,
        timestamp: Time.now,
      })
    end

    def self.merchant_cancled(merchant, net_revenue )
      Keen.publish("Merchant Cancels", {
        marketplace_name: "MarketplaceBase",
        platform_for: 'apparel',
        merchant_id: merchant.email, 
        sign_in_count: merchant.sign_in_count,
        net_revenue: net_revenue,
        year: Time.now.strftime("%Y").to_i,
        month: DateTime.now.to_date.strftime("%B"),
        day: Time.now.strftime("%d").to_i,
        day_of_week: DateTime.now.to_date.strftime("%A"),
        hour: Time.now.strftime("%H").to_i,
        minute: Time.now.strftime("%M").to_i,
        timestamp: Time.now,
        })
    end
end







