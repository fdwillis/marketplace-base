User.destroy_all
Product.destroy_all

@crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

admin = User.create!(
              name: "Admin", 
              email: 'admin@test.com', 
              password: 'pa', 
              role: 'admin',
              username: 'admin',
)

merchant = User.create!(
              name: "Merchant", 
              email: 'merchant@test.com', 
              password: 'pa', 
              role: 'merchant',
              username: 'merchant',
              card_number: @crypt.encrypt_and_sign('4242424242424242'),
              cvc_number: '433',
              exp_month: '03',
              exp_year: '2034',
              account_number: @crypt.encrypt_and_sign('000123456789'),
              routing_number: '110000000',
              tax_id: @crypt.encrypt_and_sign('000000000'),
              first_name: 'Merchant',
              last_name: 'Doe',
              business_name: 'Merchant Merchant',
              business_url: 'https://www.merchant.com',
              support_email: 'support@fa.com',
              support_phone: '4143997842',
              support_url: "https://team.com",
              dob_day: 02,
              dob_month: 12,
              dob_year: 1995,
              stripe_account_type: 'sole_prop',
              statement_descriptor: "MarketBase",
              address: '526 west wilson suite B',
              address_city: "Hordaland",
              address_state: "Western Norway",
              address_zip: 5055,
              address_country: 'NO',
              currency: 'NOK',
              bank_currency: 'NOK',
              tax_rate: 2.0,
)


admin.skip_confirmation!
admin.save!

merchant.skip_confirmation!
merchant.save!

100.times do
  Product.create!(
    user_id: 2,
    title: Faker::Name.name,
    price: 100,
    uuid: SecureRandom.uuid,
    active: true,
    product_image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Logo_NIKE.svg/2000px-Logo_NIKE.svg.png',
    quantity: 10
    )
end

p "Created #{User.count} Users"
p "Created #{Product.count} Products"

stripe = User.all.where(role: 'merchant')

stripe.each do |user|
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
        currency: user.bank_currency,
        routing_number: user.routing_number,
        account_number: @crypt.decrypt_and_verify(user.account_number),
      },
      tos_acceptance: {
        ip: '0.0.0.0',
        date: Time.now.to_i,
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
        },
      },
  )
  @stripe_account_id = @crypt.encrypt_and_sign(merchant.id)
  @merchant_secret_key = @crypt.encrypt_and_sign(merchant.keys.secret)
  @merchant_publishable_key = @crypt.encrypt_and_sign(merchant.keys.publishable)

  user.update_attributes(stripe_account_id:  @stripe_account_id , merchant_secret_key: @merchant_secret_key, merchant_publishable_key: @merchant_publishable_key )
  puts "created #{merchant.id}"
end

stripe_plan_id = [987654345678, 98765436789087, 34938872387398]

amount = [3000,50000,8000,90000,1000]

names = ['bull', 'new', 'old', 'safe', 'gold', 'apple']

stripe_plan_id.each do |id|
  stripe_plans = Stripe::Plan.create(
    amount: amount.sample,
    interval: 'month',
    name: names.sample,
    currency: 'usd',
    id: id
  )
  puts "Created #{stripe_plans.id}"
end



















