# frozen_string_literal: true

module ModelTestHelpers
  def create_user!(attrs = {})
    User.create!(default_user_attributes.merge(attrs))
  end

  def default_user_attributes
    {
      email: "user-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "First",
      last_name: "Last",
      phone_number: "0812345678"
    }
  end

  def create_admin_user!(attrs = {})
    Admin::User.create!(default_admin_user_attributes.merge(attrs))
  end

  def default_admin_user_attributes
    {
      email: "admin-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    }
  end

  def create_seller_user!(attrs = {})
    Seller::User.create!(default_seller_user_attributes.merge(attrs))
  end

  def default_seller_user_attributes
    {
      email: "seller-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "First",
      last_name: "Last",
      phone_number: "0812345678"
    }
  end

  def create_store!(attrs = {})
    owner = attrs.delete(:owner) || create_seller_user!
    Seller::Store.create!(
      {
        owner: owner,
        name: "Store #{SecureRandom.hex(3)}",
        location: "Bangkok",
        bank_code: "bbl",
        bank_number: "1234567890",
        bank_name: "Test Bank"
      }.merge(attrs)
    )
  end

  def create_standard_product!(store:, **attrs)
    Product.create!(
      {
        store: store,
        title: "Product #{SecureRandom.hex(2)}",
        sku: "SKU-#{SecureRandom.alphanumeric(8).upcase}",
        category_key: "serum",
        volume: 30,
        volume_unit: "ml",
        amount_cents: 1_000,
        promotion_cents: 0
      }.merge(attrs)
    )
  end

  def create_bundle_product!(store:, **attrs)
    Product.create!(
      {
        store: store,
        title: "Bundle #{SecureRandom.hex(2)}",
        sku: "SKU-B-#{SecureRandom.alphanumeric(8).upcase}",
        category_key: "bundle",
        kind: :bundle,
        bundle_set_type_key: "facial_routine",
        skin_concern_keys: "acne_skin",
        amount_cents: 2_000,
        promotion_cents: 0
      }.merge(attrs)
    )
  end
end
