# frozen_string_literal: true

module Seller
  class OrdersController < BaseController
    def index
      @store = current_seller_user.store
      # OrderStorePayout default_scope adds ORDER BY; PG rejects DISTINCT + ORDER BY on other columns
      order_ids = OrderStorePayout.unscope(:order)
        .where(seller_store_id: @store.id)
        .distinct
        .pluck(:order_id)
      scope = Order.where(id: order_ids).order(created_at: :desc)
      if params[:status].present? && Order.statuses.key?(params[:status])
        scope = scope.where(status: params[:status])
      end
      @orders = scope
      @status_filter = params[:status]
      ids = @orders.pluck(:id)
      @payouts_by_order_id =
        if ids.empty?
          {}
        else
          @store.order_store_payouts.where(order_id: ids).index_by(&:order_id)
        end
    end

    def show
      @store = current_seller_user.store
      @order = Order.includes(:shipping_address).find(params[:id])
      unless @store.order_store_payouts.exists?(order_id: @order.id)
        raise ActiveRecord::RecordNotFound
      end
      @payout = @store.order_store_payouts.find_by!(order_id: @order.id)
      @items = @order.order_items
        .joins(:product)
        .where(products: { seller_store_id: @store.id })
        .includes(product: { images_attachments: :blob })
    end
  end
end
