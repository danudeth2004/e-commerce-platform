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

      def purge_product_attached_images_by_signed_ids(product, signed_ids)
        signed_ids = Array(signed_ids).compact.map(&:presence).compact
        return if signed_ids.empty?

        signed_ids.each do |signed_id|
          blob = ActiveStorage::Blob.find_signed(signed_id)
          next unless blob

          attachment = product.images.attachments.find_by(blob_id: blob.id)
          attachment&.purge
        end
      end
  end
end
