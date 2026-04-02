# frozen_string_literal: true

module Users
  class ShippingAddressesController < BaseController
    before_action :authenticate_user!
    before_action :set_shipping_address, only: [ :edit, :update, :destroy, :select_for_checkout ]
    before_action :hide_app_header

    def index
      @shipping_addresses = current_user.shipping_addresses.default_first
      @order = current_user.orders.find_by(id: params[:order_id]) if params[:order_id].present?
      @return_to = safe_return_path(params[:return_to])
    end

    def new
      @shipping_address = current_user.shipping_addresses.build(
        is_default: current_user.shipping_addresses.none?
      )
      assign_checkout_context
    end

    def create
      @shipping_address = current_user.shipping_addresses.build(shipping_address_params)
      if @shipping_address.save
        apply_to_order_if_checkout(@shipping_address)
        redirect_after_save(@shipping_address)
      else
        assign_checkout_context
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      assign_checkout_context
    end

    def update
      if @shipping_address.update(shipping_address_params)
        apply_to_order_if_checkout(@shipping_address)
        redirect_after_save(@shipping_address)
      else
        assign_checkout_context
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      was_default = @shipping_address.is_default?
      @shipping_address.destroy
      if was_default && current_user.shipping_addresses.any?
        current_user.shipping_addresses.order(updated_at: :desc).first.update!(is_default: true)
      end
      redirect_to users_shipping_addresses_path(order_id: params[:order_id], return_to: params[:return_to]),
                  notice: "ลบที่อยู่แล้ว"
    end

    def select_for_checkout
      order = current_user.orders.find(params[:order_id])
      order.update!(shipping_address_id: @shipping_address.id)
      dest = safe_return_path(params[:return_to]) || payment_checkout_path(order_id: order.id)
      redirect_to dest
    end

    private

      def assign_checkout_context
        @checkout_order_id = params[:order_id].presence
        @checkout_return_to = params[:return_to].presence
      end

      def hide_app_header
        @hide_app_header = true
      end

      def set_shipping_address
        @shipping_address = current_user.shipping_addresses.find(params[:id])
      end

      def shipping_address_params
        params.require(:shipping_address).permit(
          :label,
          :recipient_name,
          :phone_number,
          :address_detail,
          :province_id,
          :district_id,
          :sub_district_id,
          :postal_code,
          :is_default
        )
      end

      def apply_to_order_if_checkout(address)
        return unless params[:order_id].present?

        order = current_user.orders.find(params[:order_id])
        order.update!(shipping_address_id: address.id)
      end

      def redirect_after_save(address)
        if params[:order_id].present?
          order = current_user.orders.find(params[:order_id])
          dest = safe_return_path(params[:return_to]) || payment_checkout_path(order_id: order.id)
          redirect_to dest, notice: "บันทึกที่อยู่แล้ว"
        elsif safe_return_path(params[:return_to])
          redirect_to safe_return_path(params[:return_to]), notice: "บันทึกที่อยู่แล้ว"
        else
          redirect_to users_shipping_addresses_path, notice: "บันทึกที่อยู่แล้ว"
        end
      end
  end
end
