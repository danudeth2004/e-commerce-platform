# frozen_string_literal: true

module Admin
  class CampaignsController < Admin::BaseController
    before_action :set_campaign, only: [ :edit, :update, :destroy ]

    def index
      @campaigns = Campaign.order(starts_at: :desc)
    end

    def new
      @campaign = Campaign.new
    end

    def create
      @campaign = Campaign.new(campaign_params)
      @campaign.from_admin_form = true
      @campaign.banner_files_for_validation = params.dig(:campaign, :banners)
      if @campaign.save
        attach_campaign_banners(@campaign)
        redirect_to admin_campaigns_path, notice: "สร้างแคมเปญแล้ว"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @campaign.update(campaign_params)
        attach_campaign_banners(@campaign)
        redirect_to admin_campaigns_path, notice: "อัปเดตแคมเปญแล้ว"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @campaign.destroy
      redirect_to admin_campaigns_path, notice: "ลบแคมเปญแล้ว"
    end

    private

    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    def campaign_params
      raw = params.require(:campaign).permit(
        :name,
        :slug,
        :starts_at,
        :ends_at,
        :discount_percent,
        product_ids: []
      )
      # อัปเดต product_ids เฉพาะเมื่อส่งมาจากฟอร์ม — ไม่เช่นนั้นจะกลายเป็น [] แล้วล้างสินค้าทั้งหมดโดยไม่ตั้งใจ
      if params[:campaign].key?(:product_ids)
        raw[:product_ids] = Array(raw[:product_ids]).reject(&:blank?).map(&:to_i)
      end
      raw
    end

    def attach_campaign_banners(campaign)
      raw = params.dig(:campaign, :banners)
      return if raw.blank?

      # รองรับทั้งหลายไฟล์ (array) และไฟล์เดียว
      files = Array(raw).flatten.compact.reject(&:blank?)
      campaign.banners.attach(files) if files.any?
    end
  end
end
