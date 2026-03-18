class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [ :payment, :pay ]
  before_action :order_paid?, only: [ :payment, :pay ]

  def create_order
    cart = current_user.cart
    return redirect_to cart_path, alert: "ไม่มีสินค้าในตะกร้า" if cart.blank? || cart.cart_items.empty?

    order = Orders::CreateFromCart.new(cart).call

    redirect_to payment_checkout_path(order_id: order.id)
  end

  def payment
    @payouts = @order.order_store_payouts
    @public_key = ENV["OMISE_PUBLIC_KEY"]
  end

  def pay
    OmiseService::CreateCharge.new(order: @order, token: params[:omise_token]).call

    if @order.paid?
      @order.order_store_payouts.each do |payout|
        TransferToStoreJob.perform_now(payout.id)
      end
      redirect_to root_path, notice: "Payment success ✅"
    else
      redirect_to root_path, alert: "Payment failed ❌"
    end
  end

  private
    def set_order
      @order = current_user.orders.find(params[:order_id])
    end

    def order_paid?
      redirect_to root_path if @order.paid?
    end
end
