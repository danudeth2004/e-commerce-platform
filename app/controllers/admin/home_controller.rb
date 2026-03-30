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
    end
  end
end
