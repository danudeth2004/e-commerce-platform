module Seller
  class StoresController < BaseController
    skip_before_action :setup_store!
    before_action :set_store, only: [:edit, :update]
    before_action :redirect_if_has_store, only: [:new, :create]

    def new
      layout "devise"

      @store = Seller::Store.new
    end

    def create
      layout "devise"

      @store = Seller::Store.new(store_params)
      @store.owner = current_seller_user

      if @store.save
        OmiseService::CreateRecipient.new(store: @store).call

        redirect_to seller_root_path, notice: "สร้างร้านค้าสำเร็จ"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @store.update(store_params)
        OmiseService::UpdateRecipient.new(store: @store).call

        redirect_to seller_root_path, notice: "แก้ไขโปรไฟล์ร้านค้าสำเร็จ"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_store
      @store = Seller::Store.find(current_seller_user.store.id)
    end

    def store_params
      params.require(:seller_store).permit(:name, :description, :location, :cover, :logo, :bank_code, :bank_number, :bank_name)
    end

    def redirect_if_has_store
      return if current_seller_user.store.blank?

      redirect_to seller_root_path
    end
  end
end