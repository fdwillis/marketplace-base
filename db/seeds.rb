User.destroy_all
Product.destroy_all

admin = User.create!(
              name: "Admin", 
              email: 'admin@test.com', 
              password: 'pa', 
              role: 'admin'
)


5.times do
  Product.create!(
    title: Faker::Name.name,
    price: Faker::Number.number(3),
    product_image: Faker::Avatar.image,
    )
end