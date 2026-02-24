class TransferToStoreJob < ApplicationJob
  queue_as :default

  def perform(payout_id)
    payout = OrderStorePayout.find(payout_id)

    return unless payout.order.paid?

    payout.with_lock do
      return unless payout.pending?
      payout.processing!
    end

    transfer = OmiseService::TransferToStore.new(payout: payout).call

    raise "Transfer failed" unless transfer

    payout.update!(
      status: :processing,
      transfer_id: transfer.id,
      transferred_at: Time.current,
    )

  rescue => e
    Rails.logger.error("[PAYOUT FAILED] #{e.message}")
    payout.update!(status: :failed) if payout&.persisted?
  end
end
