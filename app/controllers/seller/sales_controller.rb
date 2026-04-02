# frozen_string_literal: true

module Seller
  class SalesController < BaseController
    helper Seller::OrdersHelper

    SALES_CHART_DAYS = 30

    def index
      @store = current_seller_user.store
      since = SALES_CHART_DAYS.days.ago.beginning_of_day
      @daily_seller_cents = OrderStorePayout.seller_amounts_by_day_for_store(
        store_id: @store.id,
        since: since
      )
      @total_paid_seller_cents = @store.order_store_payouts
        .joins(:order)
        .merge(Order.where(status: :paid))
        .sum(:amount_cents)
      @payouts = @store.order_store_payouts.includes(:order).limit(200)
      since_date = SALES_CHART_DAYS.days.ago.to_date
      @chart_rows = (since_date..Date.current).map { |d| [ d, @daily_seller_cents[d] || 0 ] }
      max_cents = @chart_rows.map { |_, c| c }.max.to_i
      @chart_max_cents = [ max_cents, 1 ].max
      @sales_chart_days = SALES_CHART_DAYS
    end
  end
end
