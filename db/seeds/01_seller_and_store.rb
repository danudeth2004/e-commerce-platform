seller = Seller::User.find_or_create_by!(email: "demo-seller@example.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
  u.first_name = "Demo"
  u.last_name = "Seller"
  u.phone_number = "0123456789"
end

store = Seller::Store.find_or_initialize_by(seller_user_id: seller.id)
store.name ||= "Demo Store #{seller.id}"
store.location ||= "Bangkok"
store.description ||= "Seed data store"
store.save!

