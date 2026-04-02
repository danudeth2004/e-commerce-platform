# frozen_string_literal: true

module ThailandGeography
  module_function

  DATA_DIR = Rails.root.join("public/data/thailand").freeze

  def province_name(id)
    return if id.blank?

    provinces_by_id[id.to_i]&.fetch("name_th", nil)
  end

  def district_name(id)
    return if id.blank?

    districts_by_id[id.to_i]&.fetch("name_th", nil)
  end

  def sub_district_name(id)
    return if id.blank?

    sub_districts_by_id[id.to_i]&.fetch("name_th", nil)
  end

  def provinces_by_id
    @provinces_by_id ||= load_json("province.json").index_by { |r| r["id"] }
  end

  def districts_by_id
    @districts_by_id ||= load_json("district.json").index_by { |r| r["id"] }
  end

  def sub_districts_by_id
    @sub_districts_by_id ||= load_json("sub_district.json").index_by { |r| r["id"] }
  end

  def load_json(filename)
    path = DATA_DIR.join(filename)
    return [] unless path.exist?

    JSON.parse(path.read).reject { |r| r["deleted_at"].present? }
  end
end
