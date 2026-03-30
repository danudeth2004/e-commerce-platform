# frozen_string_literal: true

module Admin
  class OrderStorePayoutsController < Admin::BaseController
    def index
      @payouts = OrderStorePayout.includes(:order, store: :owner)
      if params[:status].present?
        @payouts = @payouts.where(status: params[:status].downcase)
      end
    end

    def show
      @payout = OrderStorePayout.includes(:order, store: :owner).find(params[:id])
      OmiseService::SyncTransferStatus.new(payout: @payout).call if @payout.processing?
    end

    def pay
      payout = OrderStorePayout.find(params[:id])
      unless payout.pending?
        return redirect_to admin_order_store_payout_path(payout),
          alert: "โอนได้เฉพาะรายการที่รอดำเนินการเท่านั้น"
      end

      TransferToStoreJob.perform_later(payout.id)

      redirect_to admin_order_store_payout_path(payout),
        notice: "ส่งคำสั่งโอนเงินไปยัง Omise แล้ว กรุณารอสักครู่แล้วรีเฟรชหน้านี้"
    end
  end
end
