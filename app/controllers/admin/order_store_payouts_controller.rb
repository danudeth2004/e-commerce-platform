# class Admin::OrderStorePayoutsController < Admin::BaseController
#   def show
#     @payout = OrderStorePayout.find(params[:id])
#     p "=" * 100
#     p @payout
#     OmiseService::SyncTransferStatus.new(payout: @payout).call if @payout.processing?
#   end

#   def pay
#     payout = OrderStorePayout.find(params[:order_store_payout_id])

#     TransferToStoreJob.perform_now(payout.id)

#     redirect_to payment_checkout_path(order_id: payout.order.id)
#   end
# end
