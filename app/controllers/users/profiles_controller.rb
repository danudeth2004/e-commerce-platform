# frozen_string_literal: true

module Users
  class ProfilesController < ApplicationController
    before_action :authenticate_user!

    def show
      @hide_app_header = true
      @user = current_user
      @pending_payment_items_count = OrderItem
        .joins(:order)
        .merge(current_user.orders.pending)
        .sum(:quantity)
    end
  end
end
