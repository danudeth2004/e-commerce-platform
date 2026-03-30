# frozen_string_literal: true

require "test_helper"

class HomeAndTracksTest < ActionDispatch::IntegrationTest
  test "seller preview product page when seller signed in" do
    seller = create_seller_user!
    store = create_store!(owner: seller)
    store.update!(status: :active)
    product = create_standard_product!(store: store)
    sign_in seller, scope: :seller_user

    get product_path(product, seller_preview: 1)
    assert_response :success
  end

  test "tracks_app_visit rescues errors without breaking response" do
    orig = AppVisitEvent.method(:create!)
    AppVisitEvent.define_singleton_method(:create!) { |*, **| raise StandardError, "track fail" }

    get root_path
    assert_response :success
  ensure
    AppVisitEvent.define_singleton_method(:create!, orig)
  end
end
