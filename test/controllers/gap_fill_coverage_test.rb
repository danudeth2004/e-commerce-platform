# frozen_string_literal: true

require "test_helper"

class GapFillCoverageTest < ActionDispatch::IntegrationTest
  test "seller store new redirects when store already exists" do
    seller = create_seller_user!
    create_store!(owner: seller)
    sign_in seller, scope: :seller_user

    get new_seller_store_path
    assert_redirected_to seller_root_path
  end

  test "seller store create failure renders new" do
    seller = create_seller_user!
    sign_in seller, scope: :seller_user

    post seller_stores_path, params: {
      seller_store: {
        name: "",
        location: "",
        bank_code: "",
        bank_number: "",
        bank_name: ""
      }
    }
    assert_response :unprocessable_entity
  end

  test "seller store create success" do
    seller = create_seller_user!
    sign_in seller, scope: :seller_user

    assert_difference -> { Seller::Store.count }, 1 do
      post seller_stores_path, params: {
        seller_store: {
          name: "Shop #{SecureRandom.hex(4)}",
          location: "Bangkok",
          bank_code: "bbl",
          bank_number: "1234567890",
          bank_name: "Bank"
        }
      }
    end
    assert_redirected_to seller_root_path
  end

  test "seller store edit and update" do
    seller = create_seller_user!
    store = create_store!(owner: seller)
    sign_in seller, scope: :seller_user

    get edit_seller_store_path(store)
    assert_response :success

    patch seller_store_path(store), params: {
      seller_store: {
        name: store.name,
        location: "New Loc",
        bank_code: "scb",
        bank_number: "1234567890",
        bank_name: "SCB"
      }
    }
    assert_redirected_to seller_root_path

    patch seller_store_path(store), params: {
      seller_store: {
        name: "",
        location: "",
        bank_code: "bbl",
        bank_number: "1234567890",
        bank_name: "B"
      }
    }
    assert_response :unprocessable_entity
  end

  test "seller sign out uses after_sign_out_path" do
    seller = create_seller_user!
    sign_in seller, scope: :seller_user
    delete destroy_seller_user_session_path
    assert_redirected_to new_seller_user_session_path
  end

  test "buyer registration edit uses layout" do
    user = create_user!
    sign_in user
    get edit_user_registration_path
    assert_response :success
  end

  test "admin registration update redirects to admin root" do
    admin = create_admin_user!
    sign_in admin, scope: :admin_user
    patch admin_user_registration_path, params: {
      admin_user: {
        email: admin.email,
        password: "newpassword123",
        password_confirmation: "newpassword123",
        current_password: "password123"
      }
    }
    assert_response :redirect
  end

  test "campaign update with product_ids key" do
    admin = create_admin_user!
    sign_in admin, scope: :admin_user
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store, sku: "SKU-CAMP-#{SecureRandom.hex(4)}")
    campaign = Campaign.create!(
      name: "Camp #{SecureRandom.hex(2)}",
      slug: "c-#{SecureRandom.hex(4)}",
      starts_at: 1.day.ago,
      ends_at: 1.day.from_now,
      discount_percent: 5
    )

    patch admin_campaign_path(campaign), params: {
      campaign: {
        name: campaign.name,
        slug: campaign.slug,
        starts_at: campaign.starts_at,
        ends_at: campaign.ends_at,
        discount_percent: 5,
        product_ids: [ "", product.id.to_s, "" ]
      }
    }
    assert_redirected_to admin_campaigns_path
  end

  test "cart add_item rejects zero quantity" do
    user = create_user!
    sign_in user
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store)

    post add_item_cart_path, params: { product_id: product.id, quantity: 0 }
    assert_redirected_to cart_path
  end

  test "checkout payment redirects when order already paid" do
    user = create_user!
    sign_in user
    store = create_store!
    store.update!(status: :active, omise_recipient_id: "recp_x")
    product = create_standard_product!(store: store)
    order = Order.create!(user: user, status: :paid)
    order.order_items.create!(
      product: product,
      title: product.title,
      sku: product.sku,
      quantity: 1,
      amount_cents: 100,
      amount_currency: "THB"
    )

    get payment_checkout_path(order_id: order.id)
    assert_redirected_to root_path
  end

  test "admin pay payout when not pending redirects with alert" do
    admin = create_admin_user!
    sign_in admin, scope: :admin_user
    user = create_user!
    order = Order.create!(user: user, status: :paid)
    store = create_store!
    payout = OrderStorePayout.create!(order: order, store: store, amount_cents: 100, status: :processing)

    post pay_admin_order_store_payout_path(payout)
    assert_redirected_to admin_order_store_payout_path(payout)
  end

  test "signed in user hits current_cart_item_count via profile" do
    user = create_user!
    sign_in user
    cart = Cart.create!(user: user)
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store)
    cart.cart_items.create!(product: product, quantity: 3)

    get users_profile_path
    assert_response :success
  end
end
