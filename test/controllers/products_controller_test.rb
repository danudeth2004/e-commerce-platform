# frozen_string_literal: true

require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "index renders" do
    get products_path
    assert_response :success
  end

  test "index accepts skin_concern and category params" do
    get products_path(skin_concern: "acne_skin", category: "serum")
    assert_response :success
  end

  test "index accepts search query" do
    get products_path(q: "serum")
    assert_response :success
  end
end
