# frozen_string_literal: true

require "test_helper"

class AdminResourcesTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_admin_user!
    sign_in @admin, scope: :admin_user
  end

  test "campaign create and update validation failures" do
    store = create_store!
    product = create_standard_product!(store: store, sku: "SKU-VAL-#{SecureRandom.hex(4)}")
    post admin_campaigns_path, params: {
      campaign: {
        name: "",
        slug: "x",
        starts_at: 1.day.ago,
        ends_at: 1.day.from_now,
        discount_percent: 5,
        product_ids: [ "", product.id.to_s, "" ],
        banners: [ fixture_file_upload("1x1.png", "image/png") ]
      }
    }
    assert_response :unprocessable_entity

    campaign = Campaign.create!(
      name: "Val #{SecureRandom.hex(2)}",
      slug: "val-#{SecureRandom.hex(4)}",
      starts_at: 1.day.ago,
      ends_at: 1.day.from_now,
      discount_percent: 5,
      product_ids: [ product.id ]
    )
    patch admin_campaign_path(campaign), params: {
      campaign: {
        name: campaign.name,
        slug: campaign.slug,
        starts_at: campaign.ends_at,
        ends_at: campaign.starts_at,
        discount_percent: 5,
        product_ids: [ "", product.id.to_s, "" ]
      }
    }
    assert_response :unprocessable_entity
  end

  test "campaigns index new create edit update destroy" do
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store, sku: "SKU-CAMP-CRUD-#{SecureRandom.hex(4)}")
    banner = fixture_file_upload("1x1.png", "image/png")

    get admin_campaigns_path
    assert_response :success

    get new_admin_campaign_path
    assert_response :success

    assert_difference -> { Campaign.count }, 1 do
      post admin_campaigns_path, params: {
        campaign: {
          name: "C #{SecureRandom.hex(2)}",
          slug: "c-#{SecureRandom.hex(4)}",
          starts_at: 1.day.ago,
          ends_at: 1.day.from_now,
          discount_percent: 5,
          product_ids: [ "", product.id.to_s, "" ],
          banners: [ banner ]
        }
      }
    end
    assert_redirected_to admin_campaigns_path

    campaign = Campaign.last
    get edit_admin_campaign_path(campaign)
    assert_response :success

    patch admin_campaign_path(campaign), params: {
      campaign: {
        name: campaign.name,
        slug: campaign.slug,
        starts_at: campaign.starts_at,
        ends_at: campaign.ends_at,
        discount_percent: 10,
        product_ids: [ "", product.id.to_s, "" ]
      }
    }
    assert_redirected_to admin_campaigns_path

    delete admin_campaign_path(campaign)
    assert_redirected_to admin_campaigns_path
  end

  test "stores index show set_status" do
    store = create_store!
    store.update!(status: :active)

    get admin_stores_path
    assert_response :success

    get admin_stores_path, params: { q: store.owner.email }
    assert_response :success

    get admin_store_path(store)
    assert_response :success

    get admin_store_path(store, status: "pending")
    assert_response :success

    patch set_status_admin_store_path(store), params: { status: "inactive" },
      headers: { "HTTP_REFERER" => admin_store_url(store) }
    assert_response :redirect
    assert store.reload.inactive?

    patch set_status_admin_store_path(store), params: { status: "suspended" },
      headers: { "HTTP_REFERER" => admin_store_url(store) }
    assert_response :redirect
    assert store.reload.suspended?

    patch set_status_admin_store_path(store), params: { status: "active" },
      headers: { "HTTP_REFERER" => admin_store_url(store) }
    assert_response :redirect
    assert store.reload.active?
  end

  test "set_status activates inactive store" do
    store = create_store!
    store.update!(status: :inactive)

    patch set_status_admin_store_path(store), params: { status: "active" },
      headers: { "HTTP_REFERER" => admin_store_url(store) }
    assert_response :redirect
    assert store.reload.active?
  end

  test "order_store_payouts index show pay and sync when processing" do
    user = create_user!
    order = Order.create!(user: user, status: :paid)
    store = create_store!
    payout = OrderStorePayout.create!(
      order: order,
      store: store,
      amount_cents: 100,
      status: :pending
    )

    get admin_order_store_payouts_path
    assert_response :success

    get admin_order_store_payout_path(payout)
    assert_response :success

    payout_processing = OrderStorePayout.create!(
      order: order,
      store: store,
      amount_cents: 50,
      status: :processing,
      transfer_id: "tr_x"
    )

    get admin_order_store_payout_path(payout_processing)
    assert_response :success

    assert_enqueued_jobs 0
    post pay_admin_order_store_payout_path(payout)
    assert_enqueued_jobs 1
  end

  test "payouts omise_transfer when processing" do
    user = create_user!
    order = Order.create!(user: user)
    store = create_store!
    payout = OrderStorePayout.create!(
      order: order,
      store: store,
      amount_cents: 100,
      status: :processing
    )

    post omise_transfer_admin_store_payout_path(store, payout),
      headers: { "HTTP_REFERER" => admin_store_url(store) }

    assert_redirected_to admin_store_path(store)
    assert payout.reload.transferred?
  end

  test "buyers index show and toggle_suspend" do
    buyer = create_user!

    get admin_buyers_path
    assert_response :success

    get admin_buyers_path, params: { q: buyer.email }
    assert_response :success

    get admin_buyer_path(buyer)
    assert_response :success

    assert buyer.active?
    patch toggle_suspend_admin_buyer_path(buyer)
    assert_redirected_to admin_buyer_path(buyer)
    assert buyer.reload.suspended?

    patch toggle_suspend_admin_buyer_path(buyer)
    assert_redirected_to admin_buyer_path(buyer)
    assert buyer.reload.active?
  end

  test "order_store_payouts index filters by status" do
    get admin_order_store_payouts_path, params: { status: "pending" }
    assert_response :success
  end

  test "campaign create attaches banners when files present" do
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store, sku: "SKU-WB-#{SecureRandom.hex(4)}")
    assert_difference -> { Campaign.count }, 1 do
      post admin_campaigns_path, params: {
        campaign: {
          name: "With banner #{SecureRandom.hex(2)}",
          slug: "wb-#{SecureRandom.hex(4)}",
          starts_at: 1.day.ago,
          ends_at: 1.day.from_now,
          discount_percent: 5,
          product_ids: [ "", product.id.to_s, "" ],
          banners: [ fixture_file_upload("1x1.png", "image/png") ]
        }
      }
    end
    assert_redirected_to admin_campaigns_path
    assert Campaign.last.banners.attached?
  end

  test "set_status rejects invalid status" do
    store = create_store!
    store.update!(status: :active)

    patch set_status_admin_store_path(store), params: { status: "not_a_status" },
      headers: { "HTTP_REFERER" => admin_store_url(store) }
    assert_response :redirect
    assert store.reload.active?
  end

  test "admin registration edit uses admin layout branch" do
    get edit_admin_user_registration_path
    assert_response :success
  end

  test "payouts omise_transfer rejects when not processing" do
    user = create_user!
    order = Order.create!(user: user)
    store = create_store!
    payout = OrderStorePayout.create!(
      order: order,
      store: store,
      amount_cents: 100,
      status: :pending
    )

    post omise_transfer_admin_store_payout_path(store, payout),
      headers: { "HTTP_REFERER" => admin_store_url(store) }

    assert_response :redirect
  end
end
