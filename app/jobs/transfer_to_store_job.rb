class TransferToStoreJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)
    return unless order.paid?

    order.order_store_payouts.pending.find_each do |payout|
      process_payout(payout)
    end
  end

  private

  def process_payout(payout)
    transfer = OmiseService::TransferToStore.new(payout: payout).call
    return unless transfer

    payout.update!(
      status: :transferred,
      transfer_id: transfer.id,
      transferred_at: Time.current
    )

  rescue => e
    Rails.logger.error("[PAYOUT FAILED] #{e.message}")

    payout.update!(status: :failed)
  end
end
