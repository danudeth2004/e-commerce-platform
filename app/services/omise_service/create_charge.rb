module OmiseService
  class CreateCharge
    def initialize(order:, token:, amount:)
      @order = order
      @token = token
      @amount = amount
    end

    def call
      Omise.api_key = ENV["OMISE_SECRET_KEY"]

      charge = Omise::Charge.create(
        amount: @amount,
        currency: "thb",
        card: @token,
        description: "Order ##{@order.id}"
      )

      if charge.paid
        @order.update!(
          status: :paid,
          omise_charge_id: charge.id,
          paid_at: Time.current
        )
      else
        @order.update!(
          status: :failed,
          omise_charge_id: charge.id
        )
      end

      charge
    rescue Omise::Error => e
      Rails.logger.error("OMISE ERROR: #{e.message}")

      @order.update!(status: :failed)
      nil
    end
  end
end
