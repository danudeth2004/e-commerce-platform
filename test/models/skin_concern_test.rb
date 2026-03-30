# frozen_string_literal: true

require "test_helper"

class SkinConcernTest < ActiveSupport::TestCase
  test "exposes concern data" do
    assert SkinConcern::DATA.any?
    assert SkinConcern.all.any?
  end
end
