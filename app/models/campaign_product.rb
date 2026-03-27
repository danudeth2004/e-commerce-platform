# frozen_string_literal: true

class CampaignProduct < ApplicationRecord
  belongs_to :campaign
  belongs_to :product
end
