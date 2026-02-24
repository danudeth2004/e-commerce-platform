module OmiseService
  class SyncTransferStatus
    def initialize(payout:)
      @payout = payout
    end

    def call
      return if @payout.transfer_id.blank?

      Omise.api_key = ENV.fetch("OMISE_SECRET_KEY")

      transfer = Omise::Transfer.retrieve(@payout.transfer_id)

      if transfer.sent
        @payout.update!(
          status: :transferred,
          transfer_id: transfer.id,
          transferred_at: Time.current
        )
      end

      transfer
    end
  end
end
