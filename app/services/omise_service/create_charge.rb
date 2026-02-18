module OmiseService
  class CreateCharge
    def initialize(order:, token:)
      @order = order
      @token = token
    end

    def call
      Omise.api_key = ENV["OMISE_SECRET_KEY"]

      charge = Omise::Charge.create(
        amount: @order.total_amount_cents,
        currency: "thb",
        card: @token,
        description: "Order ##{@order.id}"
      )

      if charge.paid
        @order.update!(
          status: "paid",
          omise_charge_id: charge.id,
          paid_at: Time.current
        )

        TransferToStoreJob.perform_later(@order.id)
      else
        @order.update!(
          status: "failed",
          omise_charge_id: charge.id
        )
      end

      charge
    rescue Omise::Error => e
      Rails.logger.error("OMISE ERROR: #{e.message}")

      @order.update!(status: "failed")
      nil
    end
  end
end
