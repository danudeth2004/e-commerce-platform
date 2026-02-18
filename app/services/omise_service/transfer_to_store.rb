module OmiseService
  class TransferToStore
    def initialize(payout:)
      @payout = payout
      @order = payout.order
      @store = payout.store
    end

    def call
      Omise.api_key = ENV.fetch("OMISE_SECRET_KEY")

      raise "Recipient missing" if @store.omise_recipient_id.blank?

      @payout.with_lock do
        return if @payout.transferred?
        return unless @payout.pending?

        transfer = Omise::Transfer.create(
          amount: @payout.amount_cents,
          currency: "thb",
          recipient: @store.omise_recipient_id,
          metadata: {
            order_id: @order.id,
            store_id: @store.id,
            payout_id: @payout.id
          }
        )

        transfer
      end
    end
  end
end
