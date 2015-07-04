User.destroy_all
Product.destroy_all

@crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

admin = User.create!(
              name: "Admin", 
              email: 'admin@test.com', 
              password: 'pa', 
              role: 'admin',
              username: 'admin',
              card_number: @crypt.encrypt_and_sign('4242424242424242'),
              cvc_number: '433',
              exp_month: '03',
              exp_year: '2034',
              account_number: @crypt.encrypt_and_sign('000123456789'),
              routing_number: '110000000',
              tax_id: @crypt.encrypt_and_sign('000000000'),
              first_name: 'Admin',
              last_name: 'Doe',
              business_name: 'Admin Merchant',
              business_url: 'https://www.admin.com',
              support_email: 'support@fa.com',
              support_phone: '4143997842',
              support_url: "https://team.com",
              dob_day: 23,
              dob_month: 12,
              dob_year: 1995,
              stripe_account_type: 'sole_prop',
              statement_descriptor: "MarketBase",
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
              dob_day: 23,
              dob_month: 12,
              dob_year: 1995,
              stripe_account_type: 'sole_prop',
              statement_descriptor: "MarketBase",
)

buyer = User.create!(
              name: "Buyer", 
              email: 'buyer@test.com', 
              password: 'pa', 
              role: 'buyer',
              username: 'buyer',
              card_number: @crypt.encrypt_and_sign('4242424242424242'),
              cvc_number: '433',
              exp_month: '03',
              exp_year: '2034',
              account_number: @crypt.encrypt_and_sign('000123456789'),
              routing_number: '110000000',
              tax_id: @crypt.encrypt_and_sign('000000000'),
              first_name: 'Buyer',
              last_name: 'Doe',
              business_name: 'Buyer Merchant',
              business_url: 'https://www.buyer.com',
              support_email: 'support@fa.com',
              support_phone: '4143997842',
              support_url: "https://team.com",
              dob_day: 23,
              dob_month: 12,
              dob_year: 1995,
              stripe_account_type: 'sole_prop',
              statement_descriptor: "MarketBase",
)

merchant.skip_confirmation!
merchant.save!

buyer.skip_confirmation!
buyer.save!

admin.skip_confirmation!
admin.save!

users = User.all.map(&:id)

5.times do
  Product.create!(
    user_id: users.sample,
    title: Faker::Name.name,
    price: 100,
    product_image: Faker::Avatar.image,
    uuid: SecureRandom.uuid
    )
end

p "Created #{User.count} Users"
p "Created #{Product.count} Products"