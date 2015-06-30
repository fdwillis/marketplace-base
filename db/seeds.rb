User.destroy_all
Product.destroy_all

admin = User.create!(
              name: "Admin", 
              email: 'admin@test.com', 
              password: 'pa', 
              role: 'admin'
)
admin.save!

users = User.all.map(&:id)

5.times do
  Product.create!(
    user_id: users.sample,
    title: Faker::Name.name,
    price: Faker::Number.number(3),
    product_image: Faker::Avatar.image,
    )
end

p "Created #{User.count} Users"
p "Created #{Product.count} Products"