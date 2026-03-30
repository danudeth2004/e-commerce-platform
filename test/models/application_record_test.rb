# frozen_string_literal: true

require "test_helper"

class ApplicationRecordTest < ActiveSupport::TestCase
  test "application loads ActiveRecord base" do
    assert ApplicationRecord < ActiveRecord::Base
  end
end
