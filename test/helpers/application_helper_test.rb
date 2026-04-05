# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  tests ApplicationHelper
  include Rails.application.routes.url_helpers

  test "countdown_end_unix_seconds treats millisecond epoch as seconds" do
    ms = 1_735_689_600_000
    assert_equal 1_735_689_600, countdown_end_unix_seconds(ms)
  end

  test "countdown_end_unix_seconds leaves normal unix seconds" do
    assert_equal 1_735_689_600, countdown_end_unix_seconds(1_735_689_600)
  end

  test "countdown_end_unix_seconds nil is zero" do
    assert_equal 0, countdown_end_unix_seconds(nil)
  end

  test "masked_thai_mobile blank" do
    assert_equal "—", masked_thai_mobile(nil)
  end

  test "masked_thai_mobile short number returns raw" do
    assert_equal "123", masked_thai_mobile("123")
  end

  test "masked_thai_mobile formats 10 digit" do
    s = masked_thai_mobile("0812345678")
    assert_includes s, "(+66)"
    assert_includes s, "******"
  end

  test "buyer_nav_active? unknown key is false" do
    refute buyer_nav_active?(:other)
  end

  test "signup_wizard_initial_step" do
    u = User.new
    assert_equal 1, signup_wizard_initial_step(u)

    u.errors.add(:email, "bad")
    assert_equal 1, signup_wizard_initial_step(u)

    u2 = User.new
    u2.errors.add("shipping_address.address_detail", "blank")
    assert_equal 2, signup_wizard_initial_step(u2)

    u3 = User.new
    u3.errors.add(:nickname, "bad")
    assert_equal 1, signup_wizard_initial_step(u3)
  end

  test "app_back_fallback blank referer returns root" do
    controller.request.env["HTTP_REFERER"] = nil
    assert_equal root_path, app_back_fallback
  end

  test "app_back_fallback invalid referer uri returns root" do
    controller.request.env["HTTP_REFERER"] = ":::not-a-uri"
    assert_equal root_path, app_back_fallback
  end

  test "app_back_fallback uses instance variable when set" do
    # ใน ActionView::TestCase helper รันบน instance ของเคสเทส ไม่ใช่บน controller
    instance_variable_set(:@app_back_fallback, "/custom-path")
    assert_equal "/custom-path", app_back_fallback
  end

  test "app_back_fallback returns referer when same host and different path" do
    controller.request.host = "www.example.com"
    controller.request.env["HTTP_REFERER"] = "http://www.example.com/products"
    controller.request.env["PATH_INFO"] = "/cart"
    assert_equal "http://www.example.com/products", app_back_fallback
  end

  test "app_back_fallback same path as referer returns root" do
    controller.request.host = "www.example.com"
    controller.request.env["HTTP_REFERER"] = "http://www.example.com/cart"
    controller.request.env["PATH_INFO"] = "/cart"
    assert_equal root_path, app_back_fallback
  end

  test "app_back_fallback checkout referer from cart returns root" do
    controller.request.host = "www.example.com"
    controller.request.env["HTTP_REFERER"] = "http://www.example.com/checkout/payment"
    controller.request.env["PATH_INFO"] = cart_path
    assert_equal root_path, app_back_fallback
  end
end
