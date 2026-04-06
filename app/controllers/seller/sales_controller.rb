# frozen_string_literal: true

module Seller
  class SalesController < BaseController
    helper Seller::OrdersHelper

    SALES_CHART_DAYS = 30
    MAX_RANGE_DAYS = 366

    def index
      @store = current_seller_user.store
      to_d = parse_date_param(params[:to]) || Time.zone.today
      from_d = parse_date_param(params[:from]) || (to_d - SALES_CHART_DAYS.days)
      @range_from, @range_to = clamp_date_range(from_d, to_d)

      since_time = @range_from.in_time_zone.beginning_of_day
      end_time = @range_to.in_time_zone.end_of_day

      @daily_seller_cents = OrderStorePayout.seller_amounts_by_day_for_store(
        store_id: @store.id,
        since: since_time,
        end_at: end_time
      )
      @total_paid_seller_cents = @store.order_store_payouts
        .unscope(:order)
        .joins(:order)
        .merge(Order.where(status: :paid))
        .where("orders.paid_at >= ? AND orders.paid_at <= ?", since_time, end_time)
        .sum(:amount_cents)
      @payouts = @store.order_store_payouts
        .unscope(:order)
        .joins(:order)
        .merge(Order.where(status: :paid))
        .where("orders.paid_at >= ? AND orders.paid_at <= ?", since_time, end_time)
        .includes(:order)
        .order("orders.paid_at DESC")
        .limit(200)
      @chart_rows = (@range_from..@range_to).map { |d| [ d, @daily_seller_cents[d] || 0 ] }
      max_cents = @chart_rows.map { |_, c| c }.max.to_i
      @chart_max_cents = [ max_cents, 1 ].max
      @sales_chart_days = (@range_to - @range_from).to_i + 1
    end

    private

    def parse_date_param(value)
      return nil if value.blank?

      Date.parse(value.to_s)
    rescue ArgumentError
      nil
    end

    def clamp_date_range(from_d, to_d)
      start_d = [ from_d, to_d ].min
      end_d = [ from_d, to_d ].max
      span = (end_d - start_d).to_i
      if span > MAX_RANGE_DAYS
        start_d = end_d - MAX_RANGE_DAYS.days
      end
      [ start_d, end_d ]
    end
  end
end
