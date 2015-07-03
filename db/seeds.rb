User.destroy_all
Product.destroy_all

admin = User.create!(
              name: "Admin", 
              email: 'admin@test.com', 
              password: 'pa', 
              role: 'admin',
              username: 'admin'
)

merchant = User.create!(
              name: "Merchant", 
              email: 'merchant@test.com', 
              password: 'pa', 
              role: 'merchant',
              username: 'merchant'
)

buyer = User.create!(
              name: "Buyer", 
              email: 'buyer@test.com', 
              password: 'pa', 
              role: 'buyer',
              username: 'buyer'
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