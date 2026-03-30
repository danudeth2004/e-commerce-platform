# Main seed entry point.
# This file just loads all seed parts under db/seeds/*.rb in order.
#
# Files:
#   - db/seeds/01_seller_and_store.rb
#   - db/seeds/02_products.rb
#   - db/seeds/03_flag_products.rb
#

Dir[Rails.root.join("db/seeds/*.rb")].sort.each do |seed_file|
  load seed_file
end

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
