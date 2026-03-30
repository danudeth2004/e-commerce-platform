# frozen_string_literal: true

require "test_helper"

# Exercises Seller::ProductsController and Seller::ProductBundlesController for line coverage.
class SellerProductCatalogCoverageTest < ActionDispatch::IntegrationTest
  def setup_seller_with_store
    @seller = create_seller_user!
    @store = create_store!(owner: @seller)
    @store.update!(status: :active, omise_recipient_id: "recp_test")
    sign_in @seller, scope: :seller_user
  end

  test "products choose and new" do
    setup_seller_with_store
    get choose_seller_products_path
    assert_response :success

    get new_seller_product_path
    assert_response :success
  end

  test "products create success and failure" do
    setup_seller_with_store
    assert_difference -> { @store.products.count }, 1 do
      post seller_products_path, params: {
        product: {
          title: "New P",
          sku: "SKU-#{SecureRandom.hex(4)}",
          category_key: "serum",
          volume: 30,
          volume_unit: "ml",
          amount: "100",
          promotion: "0",
          description: "d"
        }
      }
    end
    assert_redirected_to seller_root_path

    post seller_products_path, params: {
      product: {
        title: "",
        sku: "",
        category_key: "serum",
        volume: 30,
        volume_unit: "ml",
        amount: "10",
        promotion: "0"
      }
    }
    assert_response :unprocessable_entity
  end

  test "products edit redirects bundle to bundle editor" do
    setup_seller_with_store
    bundle = create_bundle_product!(store: @store, sku: "SKU-B-#{SecureRandom.hex(4)}")
    get edit_seller_product_path(bundle)
    assert_redirected_to edit_seller_product_bundle_path(bundle)
  end

  test "products edit standard" do
    setup_seller_with_store
    product = create_standard_product!(store: @store, sku: "SKU-E-#{SecureRandom.hex(4)}")
    get edit_seller_product_path(product)
    assert_response :success
  end

  test "products update standard" do
    setup_seller_with_store
    product = create_standard_product!(store: @store, sku: "SKU-U-#{SecureRandom.hex(4)}")
    patch seller_product_path(product), params: {
      product: {
        title: "Updated",
        sku: product.sku,
        category_key: "moisturizer",
        volume: 50,
        volume_unit: "ml",
        amount: "200",
        promotion: "0",
        description: "x"
      }
    }
    assert_response :redirect
  end

  test "products update bundle redirects" do
    setup_seller_with_store
    bundle = create_bundle_product!(store: @store, sku: "SKU-BU-#{SecureRandom.hex(4)}")
    patch seller_product_path(bundle), params: {
      product: {
        title: "X",
        sku: bundle.sku,
        category_key: "bundle",
        volume: 1,
        volume_unit: "ชุด",
        amount: "100",
        promotion: "0"
      }
    }
    assert_redirected_to edit_seller_product_bundle_path(bundle)
  end

  test "products destroy blocked when order exists" do
    setup_seller_with_store
    product = create_standard_product!(store: @store, sku: "SKU-D-#{SecureRandom.hex(4)}")
    user = create_user!
    order = Order.create!(user: user)
    order.order_items.create!(
      product: product,
      title: product.title,
      sku: product.sku,
      quantity: 1,
      amount_cents: 100,
      amount_currency: "THB"
    )

    delete seller_product_path(product)
    assert_response :redirect
  end

  test "products destroy blocked when used in bundle" do
    setup_seller_with_store
    comp = create_standard_product!(store: @store, sku: "SKU-COMP-#{SecureRandom.hex(4)}")
    bundle = create_bundle_product!(store: @store, sku: "SKU-BUN-#{SecureRandom.hex(4)}")
    ProductBundleItem.create!(
      bundle_product: bundle,
      component_product: comp,
      position: 0,
      usage_instructions: "u"
    )

    delete seller_product_path(comp)
    assert_response :redirect
  end

  test "products destroy success" do
    setup_seller_with_store
    product = create_standard_product!(store: @store, sku: "SKU-DEL-#{SecureRandom.hex(4)}")
    delete seller_product_path(product)
    assert_redirected_to seller_root_path
  end

  test "bundles new redirects when fewer than 2 standard products" do
    setup_seller_with_store
    create_standard_product!(store: @store, sku: "SKU-ONE-#{SecureRandom.hex(4)}")
    get new_seller_product_bundle_path
    assert_redirected_to choose_seller_products_path
  end

  test "bundles new renders when two or more standard products" do
    setup_seller_with_store
    create_standard_product!(store: @store, sku: "SKU-A-#{SecureRandom.hex(4)}")
    create_standard_product!(store: @store, sku: "SKU-B-#{SecureRandom.hex(4)}")
    get new_seller_product_bundle_path
    assert_response :success
  end

  test "bundles create validation paths" do
    setup_seller_with_store
    p1 = create_standard_product!(store: @store, sku: "SKU-P1-#{SecureRandom.hex(4)}")
    p2 = create_standard_product!(store: @store, sku: "SKU-P2-#{SecureRandom.hex(4)}")
    png = fixture_file_upload("1x1.png", "image/png")

    post seller_product_bundles_path, params: {
      product_bundle: {
        title: "",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "acne_skin" ],
        bundle_ordered_ids: [ p1.id ],
        bundle_usages: { p1.id.to_s => "u" },
        pricing_mode: "sum",
        images: [ png ]
      }
    }
    assert_response :unprocessable_entity

    post seller_product_bundles_path, params: {
      product_bundle: {
        title: "Bun",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "acne_skin" ],
        bundle_ordered_ids: [ p1.id, p2.id ],
        bundle_usages: { p1.id.to_s => "", p2.id.to_s => "u" },
        pricing_mode: "sum",
        images: [ png ]
      }
    }
    assert_response :unprocessable_entity

    post seller_product_bundles_path, params: {
      product_bundle: {
        title: "Bun",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [],
        bundle_ordered_ids: [ p1.id, p2.id ],
        bundle_usages: { p1.id.to_s => "a", p2.id.to_s => "b" },
        pricing_mode: "custom",
        bundle_amount: "-1",
        images: [ png ]
      }
    }
    assert_response :unprocessable_entity

    post seller_product_bundles_path, params: {
      product_bundle: {
        title: "Bun",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [],
        bundle_ordered_ids: [ p1.id, p2.id ],
        bundle_usages: { p1.id.to_s => "a", p2.id.to_s => "b" },
        pricing_mode: "sum",
        images: [ png ]
      }
    }
    assert_response :unprocessable_entity

    post seller_product_bundles_path, params: {
      product_bundle: {
        title: "Bun",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "acne_skin" ],
        bundle_ordered_ids: [ p1.id, p2.id ],
        bundle_usages: { p1.id.to_s => "a", p2.id.to_s => "b" },
        pricing_mode: "custom",
        bundle_amount: "0",
        images: [ png ]
      }
    }
    assert_response :unprocessable_entity
  end

  test "bundles create success" do
    setup_seller_with_store
    p1 = create_standard_product!(store: @store, sku: "SKU-S1-#{SecureRandom.hex(4)}")
    p2 = create_standard_product!(store: @store, sku: "SKU-S2-#{SecureRandom.hex(4)}")
    png = fixture_file_upload("1x1.png", "image/png")

    assert_difference -> { @store.products.bundle.count }, 1 do
      post seller_product_bundles_path, params: {
        product_bundle: {
          title: "Full Bundle",
          bundle_set_type_key: "facial_routine",
          category_key: "bundle",
          skin_concern_keys: [ "acne_skin" ],
          bundle_ordered_ids: [ p1.id, p2.id ],
          bundle_usages: { p1.id.to_s => "a", p2.id.to_s => "b" },
          pricing_mode: "sum",
          images: [ png ]
        }
      }
    end
    assert_redirected_to seller_root_path
  end

  test "bundles edit and update success" do
    setup_seller_with_store
    p1 = create_standard_product!(store: @store, sku: "SKU-E1-#{SecureRandom.hex(4)}")
    p2 = create_standard_product!(store: @store, sku: "SKU-E2-#{SecureRandom.hex(4)}")
    png = fixture_file_upload("1x1.png", "image/png")

    post seller_product_bundles_path, params: {
      product_bundle: {
        title: "Bundle Edit",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "oily_skin" ],
        bundle_ordered_ids: [ p1.id, p2.id ],
        bundle_usages: { p1.id.to_s => "a", p2.id.to_s => "b" },
        pricing_mode: "sum",
        images: [ png ]
      }
    }
    bundle = @store.products.bundle.last

    get edit_seller_product_bundle_path(bundle)
    assert_response :success

    patch seller_product_bundle_path(bundle), params: {
      product_bundle: {
        title: "Updated Bundle",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "dry_skin" ],
        bundle_ordered_ids: [ p1.id, p2.id ],
        bundle_usages: { p1.id.to_s => "a2", p2.id.to_s => "b2" },
        pricing_mode: "sum",
        images: [ png ]
      }
    }
    assert_redirected_to seller_root_path
  end

  test "bundles create redirects when store has fewer than two standard products" do
    setup_seller_with_store
    create_standard_product!(store: @store, sku: "SKU-ONLY-#{SecureRandom.hex(4)}")
    png = fixture_file_upload("1x1.png", "image/png")
    post seller_product_bundles_path, params: {
      product_bundle: {
        title: "X",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "acne_skin" ],
        bundle_ordered_ids: [],
        bundle_usages: {},
        pricing_mode: "sum",
        images: [ png ]
      }
    }
    assert_redirected_to choose_seller_products_path
  end

  test "bundles create rejects foreign component id" do
    setup_seller_with_store
    p1 = create_standard_product!(store: @store, sku: "SKU-LOC-#{SecureRandom.hex(4)}")
    p2 = create_standard_product!(store: @store, sku: "SKU-LOC2-#{SecureRandom.hex(4)}")
    other = create_standard_product!(store: create_store!(name: "Other #{SecureRandom.hex(2)}"), sku: "SKU-OTH-#{SecureRandom.hex(4)}")
    png = fixture_file_upload("1x1.png", "image/png")

    post seller_product_bundles_path, params: {
      product_bundle: {
        title: "Bad",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "acne_skin" ],
        bundle_ordered_ids: [ p1.id, other.id ],
        bundle_usages: { p1.id.to_s => "a", other.id.to_s => "b" },
        pricing_mode: "sum",
        images: [ png ]
      }
    }
    assert_response :unprocessable_entity

    post seller_product_bundles_path, params: {
      product_bundle: {
        title: "Bad2",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "acne_skin" ],
        bundle_ordered_ids: [ p1.id, p2.id ],
        bundle_usages: { p1.id.to_s => "a", p2.id.to_s => "b" },
        pricing_mode: "sum"
      }
    }
    assert_response :unprocessable_entity
  end

  test "bundles create and update rescue RecordInvalid from bundle item" do
    setup_seller_with_store
    p1 = create_standard_product!(store: @store, sku: "SKU-R1-#{SecureRandom.hex(4)}")
    p2 = create_standard_product!(store: @store, sku: "SKU-R2-#{SecureRandom.hex(4)}")
    png = fixture_file_upload("1x1.png", "image/png")

    with_bundle_item_create_invalid do
      post seller_product_bundles_path, params: {
        product_bundle: {
          title: "Rescue Create",
          bundle_set_type_key: "facial_routine",
          category_key: "bundle",
          skin_concern_keys: [ "acne_skin" ],
          bundle_ordered_ids: [ p1.id, p2.id ],
          bundle_usages: { p1.id.to_s => "a", p2.id.to_s => "b" },
          pricing_mode: "sum",
          images: [ png ]
        }
      }
      assert_response :unprocessable_entity
    end

    post seller_product_bundles_path, params: {
      product_bundle: {
        title: "For Update",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "acne_skin" ],
        bundle_ordered_ids: [ p1.id, p2.id ],
        bundle_usages: { p1.id.to_s => "a", p2.id.to_s => "b" },
        pricing_mode: "sum",
        images: [ png ]
      }
    }
    bundle = @store.products.bundle.last

    with_bundle_item_create_invalid do
      patch seller_product_bundle_path(bundle), params: {
        product_bundle: {
          title: "Rescue Update",
          bundle_set_type_key: "facial_routine",
          category_key: "bundle",
          skin_concern_keys: [ "oily_skin" ],
          bundle_ordered_ids: [ p1.id, p2.id ],
          bundle_usages: { p1.id.to_s => "a", p2.id.to_s => "b" },
          pricing_mode: "sum",
          images: [ png ]
        }
      }
      assert_response :unprocessable_entity
    end
  end

  test "bundles update validation and missing images" do
    setup_seller_with_store
    p1 = create_standard_product!(store: @store, sku: "SKU-U1-#{SecureRandom.hex(4)}")
    p2 = create_standard_product!(store: @store, sku: "SKU-U2-#{SecureRandom.hex(4)}")
    png = fixture_file_upload("1x1.png", "image/png")

    post seller_product_bundles_path, params: {
      product_bundle: {
        title: "Upd",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "acne_skin" ],
        bundle_ordered_ids: [ p1.id, p2.id ],
        bundle_usages: { p1.id.to_s => "a", p2.id.to_s => "b" },
        pricing_mode: "sum",
        images: [ png ]
      }
    }
    bundle = @store.products.bundle.last
    bundle.images.purge

    patch seller_product_bundle_path(bundle), params: {
      product_bundle: {
        title: "No Img",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "acne_skin" ],
        bundle_ordered_ids: [ p1.id, p2.id ],
        bundle_usages: { p1.id.to_s => "a", p2.id.to_s => "b" },
        pricing_mode: "sum"
      }
    }
    assert_response :unprocessable_entity

    patch seller_product_bundle_path(bundle), params: {
      product_bundle: {
        title: "One",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "acne_skin" ],
        bundle_ordered_ids: [ p1.id ],
        bundle_usages: { p1.id.to_s => "a" },
        pricing_mode: "sum",
        images: [ png ]
      }
    }
    assert_response :unprocessable_entity

    patch seller_product_bundle_path(bundle), params: {
      product_bundle: {
        title: "Neg",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "acne_skin" ],
        bundle_ordered_ids: [ p1.id, p2.id ],
        bundle_usages: { p1.id.to_s => "a", p2.id.to_s => "b" },
        pricing_mode: "custom",
        bundle_amount: "-5",
        images: [ png ]
      }
    }
    assert_response :unprocessable_entity

    patch seller_product_bundle_path(bundle), params: {
      product_bundle: {
        title: "Skin",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [],
        bundle_ordered_ids: [ p1.id, p2.id ],
        bundle_usages: { p1.id.to_s => "a", p2.id.to_s => "b" },
        pricing_mode: "sum",
        images: [ png ]
      }
    }
    assert_response :unprocessable_entity

    patch seller_product_bundle_path(bundle), params: {
      product_bundle: {
        title: "C0",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "acne_skin" ],
        bundle_ordered_ids: [ p1.id, p2.id ],
        bundle_usages: { p1.id.to_s => "a", p2.id.to_s => "b" },
        pricing_mode: "custom",
        bundle_amount: "0",
        images: [ png ]
      }
    }
    assert_response :unprocessable_entity

    patch seller_product_bundle_path(bundle), params: {
      product_bundle: {
        title: "Usage",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "acne_skin" ],
        bundle_ordered_ids: [ p1.id, p2.id ],
        bundle_usages: { p1.id.to_s => "", p2.id.to_s => "b" },
        pricing_mode: "sum",
        images: [ png ]
      }
    }
    assert_response :unprocessable_entity

    foreign = create_standard_product!(store: create_store!(name: "F #{SecureRandom.hex(2)}"), sku: "SKU-FOR-#{SecureRandom.hex(4)}")
    patch seller_product_bundle_path(bundle), params: {
      product_bundle: {
        title: "Foreign",
        bundle_set_type_key: "facial_routine",
        category_key: "bundle",
        skin_concern_keys: [ "acne_skin" ],
        bundle_ordered_ids: [ p1.id, foreign.id ],
        bundle_usages: { p1.id.to_s => "a", foreign.id.to_s => "b" },
        pricing_mode: "sum",
        images: [ png ]
      }
    }
    assert_response :unprocessable_entity
  end

  test "products update standard failure and attach image" do
    setup_seller_with_store
    product = create_standard_product!(store: @store, sku: "SKU-FAIL-#{SecureRandom.hex(4)}")
    patch seller_product_path(product), params: {
      product: {
        title: "",
        sku: product.sku,
        category_key: "serum",
        volume: 30,
        volume_unit: "ml",
        amount: "100",
        promotion: "0",
        description: "x"
      }
    }
    assert_response :unprocessable_entity

    png = fixture_file_upload("1x1.png", "image/png")
    patch seller_product_path(product), params: {
      product: {
        title: "With Img",
        sku: product.sku,
        category_key: "serum",
        volume: 30,
        volume_unit: "ml",
        amount: "150",
        promotion: "0",
        description: "x",
        images: [ png ]
      }
    }
    assert_response :redirect
    assert product.reload.images.attached?
  end

  test "products update clears promotion when blank string" do
    setup_seller_with_store
    product = create_standard_product!(
      store: @store,
      sku: "SKU-PROM-#{SecureRandom.hex(4)}",
      promotion_cents: 500,
      promotion_starts_at: 1.day.ago,
      promotion_ends_at: 1.day.from_now
    )
    patch seller_product_path(product), params: {
      product: {
        title: product.title,
        sku: product.sku,
        category_key: "serum",
        volume: 30,
        volume_unit: "ml",
        amount: "10",
        promotion: "",
        description: "x"
      }
    }
    assert_response :redirect
    assert_equal 0, product.reload.promotion_cents
  end

  private

  def with_bundle_item_create_invalid
    sc = ProductBundleItem.singleton_class
    sc.alias_method :__orig_bundle_create!, :create!
    sc.define_method(:create!) do |*|
      r = ProductBundleItem.new
      r.errors.add(:base, "x")
      raise ActiveRecord::RecordInvalid.new(r)
    end
    yield
  ensure
    sc.alias_method :create!, :__orig_bundle_create!
    sc.remove_method :__orig_bundle_create!
  end
end
