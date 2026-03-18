class Admin::PayoutsController < Admin::BaseController
  def omise_transfer
    payout = OrderStorePayout.find(params[:id])
    return redirect_back(fallback_location: admin_store_path(payout.store), alert: "ไม่สามารถโอนเงินได้") unless payout.status == "processing"

    payout.update!(status: "transferred")

    redirect_back fallback_location: admin_store_path(payout.store)
  end
end
