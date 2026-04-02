# frozen_string_literal: true

module Admin
  class BuyersController < BaseController
    before_action :set_buyer, only: %i[show toggle_suspend]

    def index
      @buyers = ::User.order(created_at: :desc)
      if params[:q].present?
        term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q].strip)}%"
        @buyers = @buyers.where(
          "email ILIKE :t OR first_name ILIKE :t OR last_name ILIKE :t OR phone_number ILIKE :t",
          t: term
        )
      end
      @buyers = @buyers.limit(200)
    end

    def show
      @orders = @buyer.orders.order(created_at: :desc).limit(50)
    end

    def toggle_suspend
      if @buyer.suspended?
        @buyer.active!
        notice = "เปิดใช้งานบัญชีลูกค้าแล้ว"
      else
        @buyer.suspended!
        notice = "ระงับบัญชีลูกค้าแล้ว"
      end
      redirect_to admin_buyer_path(@buyer), notice: notice
    end

    private

      def set_buyer
        @buyer = ::User.find(params[:id])
      end
  end
end
