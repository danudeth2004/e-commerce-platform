module Seller
  class BaseController < ::ApplicationController
    layout "seller"
    before_action :authenticate_seller_user!
    before_action :setup_store!
    before_action :ensure_store_not_suspended!, if: :seller_store_suspended?

    private

      def seller_store_suspended?
        current_seller_user&.store&.suspended?
      end

      def ensure_store_not_suspended!
        return if controller_name == "home"

        redirect_to seller_root_path,
          alert: "ร้านของคุณถูกระงับการขายชั่วคราว กรุณาติดต่อผู้ดูแลระบบ"
      end

      def setup_store!
        return if current_seller_user.store.present?

        redirect_to new_seller_store_path,
          alert: "กรุณาสร้างบัญชีร้านค้าของคุณก่อนเริ่มใช้งาน"
      end
  end
end
