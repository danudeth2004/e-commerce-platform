# frozen_string_literal: true

module Admin
  class HomeController < BaseController
    def index
      @store_count = Seller::Store.count
      @campaign_count = Campaign.count
      @payout_pending_count = OrderStorePayout.pending.count
      @payout_processing_count = OrderStorePayout.processing.count

      @usage_days = 30
      since = @usage_days.days.ago.beginning_of_day
      visit_h = AppVisitEvent.counts_by_day(since: since)
      sess_h = AppVisitEvent.distinct_sessions_by_day(since: since)
      order_h = Order.paid_counts_by_day(since: since)

      dates = (since.to_date..Time.zone.today).to_a
      @chart_labels = dates.map { |d| d.strftime("%d/%m") }
      @visit_series = dates.map { |d| visit_h[d] || 0 }
      @session_series = dates.map { |d| sess_h[d] || 0 }
      @order_series = dates.map { |d| order_h[d] || 0 }

      assign_revenue_dashboard(since:, dates:)
    end

    private

    def assign_revenue_dashboard(since:, dates:)
      fin_h = Order.paid_financials_by_day(since: since)
      seller_h = OrderStorePayout.seller_amounts_by_day_for_paid_orders(since: since)

      @revenue_gmv_series = dates.map { |d| (fin_h[d]&.dig(:gmv_cents).to_i / 100.0) }
      @revenue_platform_series = dates.map { |d| (fin_h[d]&.dig(:platform_fee_cents).to_i / 100.0) }
      @revenue_seller_series = dates.map { |d| (seller_h[d].to_i / 100.0) }

      paid_scope = Order.where(status: :paid).where("paid_at >= ?", since)
      @total_gmv_cents = paid_scope.sum(:total_amount_cents)
      @total_platform_fee_cents = paid_scope.sum(:platform_fee_cents)
      @total_seller_payout_cents = OrderStorePayout.unscoped
        .joins(:order)
        .merge(Order.where(status: :paid))
        .where("orders.paid_at >= ?", since)
        .sum("order_store_payouts.amount_cents")

      @revenue_margin_percent = @total_gmv_cents.positive? ? ((@total_platform_fee_cents.to_f / @total_gmv_cents) * 100).round(1) : 0.0
      @revenue_balance_check_cents = @total_gmv_cents - @total_platform_fee_cents - @total_seller_payout_cents
    end
  end
end
