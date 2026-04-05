module Seller
  class ProductBundlesController < BaseController
    layout "devise"
    before_action :set_store
    before_action :set_bundle_product, only: [ :edit, :update ]

    def new
      @candidates = @store.products.standard.order(:title)
      if @candidates.size < 2
        redirect_to choose_seller_products_path,
          alert: "ต้องมีสินค้าในร้านอย่างน้อย 2 รายการก่อนจัดเซต — กรุณาเพิ่มสินค้าชิ้นเดียวก่อน"
        return
      end

      set_candidate_prices
    end

    def create
      @candidates = @store.products.standard.order(:title)
      if @candidates.size < 2
        redirect_to choose_seller_products_path, alert: "สินค้าในร้านไม่เพียงพอสำหรับการจัดเซต"
        return
      end

      set_candidate_prices

      ordered_ids = parse_ordered_ids
      usages = parse_usages(ordered_ids)
      p = product_bundle_params

      if ordered_ids.size < 2
        flash.now[:alert] = "กรุณาเลือกสินค้าอย่างน้อย 2 รายการ และเรียงลำดับการใช้"
        render :new, status: :unprocessable_entity
        return
      end

      if ordered_ids.any? { |id| usages[id].blank? }
        flash.now[:alert] = "กรุณากรอกวิธีการใช้งานให้ครบทุกชิ้นในเซต"
        render :new, status: :unprocessable_entity
        return
      end

      components_by_id = @store.products.standard.where(id: ordered_ids).index_by(&:id)
      if ordered_ids.any? { |id| components_by_id[id].blank? }
        flash.now[:alert] = "มีสินค้าที่เลือกไม่ถูกต้องหรือไม่ใช่สินค้าชิ้นเดียวในร้านนี้"
        render :new, status: :unprocessable_entity
        return
      end

      sum_cents = ordered_ids.sum { |id| components_by_id[id].final_price_cents }
      amount_cents =
        if p[:pricing_mode] == "custom"
          (p[:bundle_amount].to_f * 100).round
        else
          sum_cents
        end

      if amount_cents.negative?
        flash.now[:alert] = "ราคาเซตไม่ถูกต้อง"
        render :new, status: :unprocessable_entity
        return
      end

      skin_keys = normalized_skin_concern_keys
      if skin_keys.empty?
        flash.now[:alert] = "กรุณาเลือกปัญหาผิวที่เหมาะกับเซตอย่างน้อย 1 ข้อ"
        render :new, status: :unprocessable_entity
        return
      end

      if p[:pricing_mode] == "custom" && p[:bundle_amount].to_f <= 0
        flash.now[:alert] = "กรุณาระบุราคาเซตเมื่อเลือกตั้งราคาพิเศษ"
        render :new, status: :unprocessable_entity
        return
      end

      @product = @store.products.build(
        kind: :bundle,
        title: p[:title],
        description: p[:description],
        category_key: p[:category_key].presence || "bundle",
        skin_concern_keys: skin_keys.join(","),
        skin_concern_key: skin_keys.first,
        bundle_set_type_key: p[:bundle_set_type_key],
        effect: p[:effect].presence,
        usage: p[:usage].presence,
        amount_cents: amount_cents,
        volume: 1,
        volume_unit: "ชุด",
        promotion_cents: 0,
        promotion_currency: "THB"
      )

      attach_new_images_if_any(@product)

      unless @product.images.attached?
        flash.now[:alert] = "กรุณาอัปโหลดรูปสินค้า"
        render :new, status: :unprocessable_entity
        return
      end

      Product.transaction do
        @product.save!
        ordered_ids.each_with_index do |cid, i|
          ProductBundleItem.create!(
            bundle_product: @product,
            component_product_id: cid,
            position: i,
            usage_instructions: usages[cid].to_s.strip
          )
        end
      end

      redirect_to seller_root_path, notice: "สร้างเซตสินค้าเรียบร้อยแล้ว"
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = e.record.errors.full_messages.to_sentence.presence || "ไม่สามารถบันทึกเซตได้"
      render :new, status: :unprocessable_entity
    end

    def edit
      @candidates = @store.products.standard.order(:title)
      # :nocov:
      if @candidates.size < 2
        redirect_to choose_seller_products_path,
          alert: "ต้องมีสินค้าในร้านอย่างน้อย 2 รายการก่อนจัดเซต — กรุณาเพิ่มสินค้าชิ้นเดียวก่อน"
        return
      end
      # :nocov:
      set_candidate_prices
      setup_bundle_form_defaults
    end

    def update
      @candidates = @store.products.standard.order(:title)
      set_candidate_prices

      ordered_ids = parse_ordered_ids
      usages = parse_usages(ordered_ids)
      p = product_bundle_params

      if ordered_ids.size < 2
        flash.now[:alert] = "กรุณาเลือกสินค้าอย่างน้อย 2 รายการ และเรียงลำดับการใช้"
        assign_bundle_edit_form_state!
        render :edit, status: :unprocessable_entity
        return
      end

      if ordered_ids.any? { |id| usages[id].blank? }
        flash.now[:alert] = "กรุณากรอกวิธีการใช้งานให้ครบทุกชิ้นในเซต"
        assign_bundle_edit_form_state!
        render :edit, status: :unprocessable_entity
        return
      end

      components_by_id = @store.products.standard.where(id: ordered_ids).index_by(&:id)
      if ordered_ids.any? { |id| components_by_id[id].blank? }
        flash.now[:alert] = "มีสินค้าที่เลือกไม่ถูกต้องหรือไม่ใช่สินค้าชิ้นเดียวในร้านนี้"
        assign_bundle_edit_form_state!
        render :edit, status: :unprocessable_entity
        return
      end

      sum_cents = ordered_ids.sum { |id| components_by_id[id].final_price_cents }
      amount_cents =
        if p[:pricing_mode] == "custom"
          (p[:bundle_amount].to_f * 100).round
        else
          sum_cents
        end

      if amount_cents.negative?
        flash.now[:alert] = "ราคาเซตไม่ถูกต้อง"
        assign_bundle_edit_form_state!
        render :edit, status: :unprocessable_entity
        return
      end

      skin_keys = normalized_skin_concern_keys
      if skin_keys.empty?
        flash.now[:alert] = "กรุณาเลือกปัญหาผิวที่เหมาะกับเซตอย่างน้อย 1 ข้อ"
        assign_bundle_edit_form_state!
        render :edit, status: :unprocessable_entity
        return
      end

      if p[:pricing_mode] == "custom" && p[:bundle_amount].to_f <= 0
        flash.now[:alert] = "กรุณาระบุราคาเซตเมื่อเลือกตั้งราคาพิเศษ"
        assign_bundle_edit_form_state!
        render :edit, status: :unprocessable_entity
        return
      end

      had_images = @product.images.attachments.exists?
      purge_product_attached_images_by_signed_ids(@product, p[:remove_image_signed_ids])
      attach_new_images_if_any(@product)
      @product.images.reload

      if !@product.images.attached? && had_images
        flash.now[:alert] = "กรุณามีรูปเซตอย่างน้อย 1 รูป (อัปโหลดเพิ่มหรือใช้รูปเดิม)"
        assign_bundle_edit_form_state!
        render :edit, status: :unprocessable_entity
        return
      end

      @product.assign_attributes(
        title: p[:title],
        description: p[:description],
        category_key: p[:category_key].presence || "bundle",
        skin_concern_keys: skin_keys.join(","),
        skin_concern_key: skin_keys.first,
        bundle_set_type_key: p[:bundle_set_type_key],
        effect: p[:effect].presence,
        usage: p[:usage].presence,
        amount_cents: amount_cents,
        volume: 1,
        volume_unit: "ชุด",
        promotion_cents: 0,
        promotion_currency: "THB"
      )

      Product.transaction do
        @product.save!
        @product.bundle_items.destroy_all
        ordered_ids.each_with_index do |cid, i|
          ProductBundleItem.create!(
            bundle_product: @product,
            component_product_id: cid,
            position: i,
            usage_instructions: usages[cid].to_s.strip
          )
        end
      end

      redirect_to seller_root_path, notice: "อัปเดตเซตสินค้าเรียบร้อยแล้ว"
    rescue ActiveRecord::RecordInvalid => e
      @product.reload
      flash.now[:alert] = e.record.errors.full_messages.to_sentence.presence || "ไม่สามารถบันทึกเซตได้"
      assign_bundle_edit_form_state!
      render :edit, status: :unprocessable_entity
    end

    private

    def set_bundle_product
      @product = @store.products.where(kind: :bundle).find(params[:id])
    end

    def set_store
      @store = Seller::Store.find(current_seller_user.store.id)
    end

    def setup_bundle_form_defaults
      @order_ids = @product.bundle_items.order(:position).pluck(:component_product_id)
      @usages_by_id = @product.bundle_items.order(:position).each_with_object({}) do |item, h|
        h[item.component_product_id] = item.usage_instructions
      end
      sum_cents = @order_ids.sum { |id| @candidate_prices[id.to_s] || @candidate_prices[id] || 0 }
      @pricing_mode = (@product.amount_cents == sum_cents) ? "sum" : "custom"
      @bundle_amount_baht = (@product.amount_cents / 100.0)
    end

    def assign_bundle_edit_form_state!
      @order_ids = parse_ordered_ids.presence || @product.bundle_items.order(:position).pluck(:component_product_id)
      p = product_bundle_params
      @usages_by_id = {}
      @order_ids.each do |id|
        raw = params.dig(:product_bundle, :bundle_usages, id.to_s) || params.dig(:product_bundle, :bundle_usages, id.to_s.to_sym)
        @usages_by_id[id] = raw.presence || @product.bundle_items.find_by(component_product_id: id)&.usage_instructions
      end
      sum_cents = @order_ids.sum { |id| @candidate_prices[id.to_s] || @candidate_prices[id] || 0 }
      @pricing_mode = p[:pricing_mode].presence || ((@product.amount_cents == sum_cents) ? "sum" : "custom")
      @bundle_amount_baht = if p[:bundle_amount].present?
        p[:bundle_amount].to_f
      else
        (@product.amount_cents / 100.0)
      end
    end

    def set_candidate_prices
      @candidate_prices = @candidates.map { |p| [ p.id.to_s, p.final_price_cents ] }.to_h
    end

    def product_bundle_params
      params.require(:product_bundle).permit(
        :title,
        :description,
        :category_key,
        :bundle_set_type_key,
        :effect,
        :usage,
        :pricing_mode,
        :bundle_amount,
        bundle_ordered_ids: [],
        skin_concern_keys: [],
        images: [],
        remove_image_signed_ids: []
      )
    end

    def normalized_skin_concern_keys
      raw = params.dig(:product_bundle, :skin_concern_keys)
      allowed = SkinConcern::DATA.map { |d| d[:key] }
      Array(raw).map(&:presence).compact.uniq.select { |k| allowed.include?(k) }
    end

    def parse_ordered_ids
      raw = params.dig(:product_bundle, :bundle_ordered_ids)
      Array(raw).map(&:to_i).reject(&:zero?)
    end

    def parse_usages(ordered_ids)
      hash = params.dig(:product_bundle, :bundle_usages)
      return {} if hash.blank?

      h = hash.respond_to?(:to_unsafe_h) ? hash.to_unsafe_h : hash.to_h
      ordered_ids.index_with do |id|
        h[id.to_s].presence || h[id.to_s.to_sym]
      end
    end

    def attach_new_images_if_any(product)
      files = params.dig(:product_bundle, :images)
      return if files.blank?

      files = Array(files).compact.reject(&:blank?)
      product.images.attach(files) if files.any?
    end
  end
end
