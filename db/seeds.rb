User.destroy_all
Product.destroy_all

@crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

admin = User.create!(
              name: "Admin", 
              email: 'admin@test.com', 
              password: 'pa', 
              role: 'admin',
              username: 'admin',
              card_number: @crypt.encrypt_and_sign('4000000000000077'),
              cvc_number: '433',
              exp_month: '03',
              exp_year: '2034',
              account_number: @crypt.encrypt_and_sign('000123456789'),
              routing_number: '110000000',
              tax_id: @crypt.encrypt_and_sign('000000000'),
              first_name: 'Admin',
              last_name: 'Doe',
              business_name: 'Admin',
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
              address_city: "Madison",
              address_state: "WI",
              address_zip: 53703,
              address_country: 'US',
              currency: 'USD',
              bank_currency: 'USD',
              tax_rate: 3.0,
              legal_name: "Full Admin"
)

merchant = User.create!(
              name: "Merchant", 
              email: 'merch@test.com', 
              password: 'pa', 
              username: 'merchant',
              card_number: @crypt.encrypt_and_sign('4000000000000077'),
              cvc_number: '433',
              exp_month: '03',
              exp_year: '2034',
              account_number: @crypt.encrypt_and_sign('000123456789'),
              routing_number: '110000000',
              tax_id: @crypt.encrypt_and_sign('000000000'),
              first_name: 'Merchant',
              last_name: 'Doe',
              business_name: 'Merchant 98kj',
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
              address_city: "Madison",
              address_state: "WI",
              address_zip: 53703,
              address_country: 'US',
              currency: 'USD',
              bank_currency: 'USD',
              tax_rate: 2.0,
              legal_name: "Full Test Merch",
              account_approved: true,
)

@crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
a = User.create!(
  email: 'a@a.com',
  password: 'pa',
  business_name: '34',
  card_number: @crypt.encrypt_and_sign('4000000000000077'), 
  exp_year: '2018',
  exp_month: '09',
  cvc_number: '3333',
  legal_name: 'full legal',
  username: 'full_',
  address_country: "US",
  currency: "USD",
  country_name: "United States",
  support_phone: 4143997341
  )
a.skip_confirmation!
a.save!

admin.skip_confirmation!
admin.save!
admin.roles.create(title: 'admin')

merchant.skip_confirmation!
merchant.save!
merchant.roles.create([{title: 'donations'}, {title: 'merchant'}])

20.times do
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



















