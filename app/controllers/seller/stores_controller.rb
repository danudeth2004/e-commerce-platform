module Seller
  class StoresController < BaseController
    layout "devise"
    skip_before_action :setup_store!, only: [:new, :create]
    before_action :redirect_if_has_store

    def new
      @store = Seller::Store.new
    end

    def create
      @store = Seller::Store.new(store_params)
      @store.owner = current_seller_user

      if @store.save
        OmiseService::CreateRecipient.new(store: @store).call

        redirect_to seller_root_path, notice: "สร้างร้านค้าสำเร็จ"
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def store_params
      params.require(:seller_store).permit(:name, :description, :location, :cover, :logo, :bank_code, :bank_number, :bank_name)
    end

    def redirect_if_has_store
      return if current_seller_user.store.blank?

      redirect_to seller_root_path
    end
  end
end