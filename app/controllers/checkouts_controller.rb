# class CheckoutsController < ApplicationController
#   before_action :authenticate_user!

#   def create_order
#     cart = current_user.cart

#     order = Orders::CreateFromCart.new(cart).call

#     redirect_to payment_checkout_path(order_id: order.id)
#   end

#   def payment
#     @order = current_user.orders.find(params[:order_id])
#     @payouts = @order.order_store_payouts
#     @public_key = ENV["OMISE_PUBLIC_KEY"]
#   end

#   def pay
#     order = current_user.orders.find(params[:order_id])

#     OmiseService::CreateCharge.new(order: order, token: params[:omise_token]).call

#     if order.paid?
#       redirect_to payment_checkout_path(order_id: order.id), notice: "Payment success ✅"
#     else
#       redirect_to payment_checkout_path(order_id: order.id), alert: "Payment failed ❌"
#     end
#   end
# end
