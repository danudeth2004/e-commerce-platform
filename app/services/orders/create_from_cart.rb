module Orders
  class CreateFromCart
    def initialize(source, user:)
      @source = source
      @user = user
    end

    def call
      Order.transaction do
        order = @user.orders.create!(
          total_amount_cents: 0,
          platform_fee_cents: 0,
        )

        create_order_items(order)
        recalculate_order_amount!(order)
        create_store_payouts(order)
        clear_cart_if_needed

        order
      end
    end

    private

    def source_items
      if @source.respond_to?(:cart_items)
        @source.cart_items
      else
        @source
      end
    end

    def create_order_items(order)
      source_items.includes(:product).each do |item|
        product = item.product

        order.order_items.create!(
          product: product,
          title: product.title,
          sku: product.sku,
          quantity: item.quantity,
          amount_cents: product.final_price_cents
        )
      end
    end

    def recalculate_order_amount!(order)
      order_total = order.order_items.sum do |item|
        item.amount_cents * item.quantity
      end

      platform_fee = (order_total * 0.1).to_i

      order.update!(
        total_amount_cents: order_total,
        platform_fee_cents: platform_fee
      )
    end

    def create_store_payouts(order)
      grouped = order
        .order_items
        .includes(product: :store)
        .group_by { |item| item.product.store }

      total_order_amount = order.total_amount_cents
      total_platform_fee = order.platform_fee_cents

      return if total_order_amount.zero?

      fee_ratio = total_platform_fee.to_f / total_order_amount

      grouped.each do |store, items|
        store_total = items.sum do |item|
          item.amount_cents * item.quantity
        end

        platform_cut = (store_total * fee_ratio).round
        seller_amount = store_total - platform_cut

        OrderStorePayout.create!(
          order: order,
          store: store,
          amount_cents: seller_amount
        )
      end
    end

    def clear_cart_if_needed
      return unless @source.respond_to?(:cart_items)
      @source.cart_items.destroy_all
    end
  end
end
