module Seller
  class BaseController < ::ApplicationController
    layout "seller"
    before_action :authenticate_seller_user!
    before_action :setup_store!

    private

      def setup_store!
        return if current_seller_user.store.present?

        redirect_to new_seller_store_path,
          alert: "กรุณาสร้างบัญชีร้านค้าของคุณก่อนเริ่มใช้งาน"
      end
  end
end
