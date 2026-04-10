# frozen_string_literal: true

module Users
  class ProfilesController < ApplicationController
    before_action :authenticate_user!

    def show
      @user = current_user
      @pending_payment_orders_count = current_user.orders.pending.count
      @coupons = current_user.coupons.active.includes(:products).order(created_at: :desc)
    end
  end
end
