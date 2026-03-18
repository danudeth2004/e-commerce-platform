module Admin
  class StoresController < BaseController
    before_action :set_store, only: [ :show, :toggle_status ]

    def index
      @stores = Seller::Store.all
    end

    def show
      @selected_status = params[:status] || "all"

      @payouts =
      if @selected_status == "all"
        @store.order_store_payouts
      else
        @store.order_store_payouts.where(status: @selected_status)
      end
    end

    def toggle_status
      if @store.active?
        @store.inactive!
      else
        @store.active!
      end
      @store.save
      redirect_back fallback_location: admin_store_path(@store), notice: "เปลี่ยนสถานะร้านค้าเรียบร้อยแล้ว"
    end

    private

      def set_store
        @store = Seller::Store.find(params[:id])
      end
  end
end
