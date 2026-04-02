module Admin
  class StoresController < BaseController
    before_action :set_store, only: %i[show set_status]

    def index
      @stores = Seller::Store.includes(:owner).order(id: :asc)
      if params[:q].present?
        term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q].strip)}%"
        @stores = @stores.left_joins(:owner).where(
          "seller_stores.name ILIKE :t OR seller_users.email ILIKE :t OR " \
          "seller_users.first_name ILIKE :t OR seller_users.last_name ILIKE :t OR " \
          "COALESCE(seller_users.phone_number, '') ILIKE :t",
          t: term
        )
      end
      @stores = @stores.limit(200)
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

    def set_status
      st = params[:status].to_s
      unless %w[active inactive suspended].include?(st)
        redirect_back fallback_location: admin_store_path(@store), alert: "สถานะไม่ถูกต้อง"
        return
      end

      @store.update!(status: st)
      redirect_back fallback_location: admin_store_path(@store), notice: "อัปเดตสถานะร้านแล้ว"
    end

    private

      def set_store
        @store = Seller::Store.find(params[:id])
      end
  end
end
