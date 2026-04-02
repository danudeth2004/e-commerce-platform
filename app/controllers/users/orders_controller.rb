# frozen_string_literal: true

module Users
  class OrdersController < ApplicationController
    before_action :authenticate_user!
    before_action :default_buyer_hub_back_fallback, only: [ :index, :show ]

    def index
      @orders = current_user.orders.order(created_at: :desc).includes(order_items: :product)
      if params[:status].present? && Order.statuses.key?(params[:status])
        @orders = @orders.where(status: params[:status])
      end
      @status_filter = params[:status]
    end

    def show
      @order = current_user.orders.includes(:shipping_address).find(params[:id])
    end

    private

    def default_buyer_hub_back_fallback
      return if request.referer.present?

      @app_back_fallback = users_profile_path
    end
  end
end
