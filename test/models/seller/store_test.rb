# frozen_string_literal: true

require "test_helper"

class Seller::StoreTest < ActiveSupport::TestCase
  test "valid with all required fields" do
    store = create_store!
    assert store.persisted?
    assert store.inactive?
  end

  test "normalizes bank_number to digits" do
    store = create_store!(bank_number: "123-456-789-012")
    assert_equal "123456789012", store.bank_number
  end

  test "rejects invalid bank_code" do
    store = build_store(bank_code: "xxx")
    assert_not store.valid?
    assert_includes store.errors[:bank_code], "ไม่อยู่ในรายการที่กำหนด"
  end

  test "rejects bank_number with wrong length" do
    store = build_store(bank_number: "12345")
    assert_not store.valid?
  end

  test "name must be unique" do
    s1 = create_store!
    store = build_store(name: s1.name, owner: create_seller_user!)
    assert_not store.valid?
  end

  private

  def build_store(attrs = {})
    owner = attrs.delete(:owner) || create_seller_user!
    Seller::Store.new(
      {
        owner: owner,
        name: attrs[:name] || "Store #{SecureRandom.hex(3)}",
        location: "Bangkok",
        bank_code: "scb",
        bank_number: "1234567890",
        bank_name: "Bank"
      }.merge(attrs)
    )
  end
end
