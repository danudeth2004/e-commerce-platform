# frozen_string_literal: true

require "test_helper"

# Subclass used only in this test file — must expose the same route as Seller::HomeController.
class SellerHomeElseBranchController < Seller::HomeController
  def self.controller_path
    "seller/home"
  end

  skip_before_action :authenticate_seller_user!, raise: false
  skip_before_action :setup_store!, raise: false

  def current_seller_user
    @stub_seller ||= Struct.new(:store).new(Seller::Store.new(id: 1))
  end
end

class SellerHomeElseBranchTest < ActionController::TestCase
  tests SellerHomeElseBranchController

  test "index uses empty collections when store is not persisted" do
    get :index
    assert_response :success
    assert_equal [], @controller.view_assigns["products"]
    assert_equal 0, @controller.view_assigns["bundle_products"].count
    assert_equal 0, @controller.view_assigns["standard_products"].count
  end
end
