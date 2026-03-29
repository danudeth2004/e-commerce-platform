# frozen_string_literal: true

module Users
  class OrdersController < ApplicationController
    before_action :authenticate_user!

    def index
      @hide_app_header = true
      @orders = current_user.orders.order(created_at: :desc).includes(order_items: :product)
      if params[:status].present? && Order.statuses.key?(params[:status])
        @orders = @orders.where(status: params[:status])
      end
      @status_filter = params[:status]
    end

    def show
      @hide_app_header = true
      @order = current_user.orders.find(params[:id])
    end
  end
end
