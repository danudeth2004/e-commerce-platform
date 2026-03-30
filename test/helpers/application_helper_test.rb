# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  tests ApplicationHelper

  test "masked_thai_mobile blank" do
    assert_equal "—", masked_thai_mobile(nil)
  end

  test "masked_thai_mobile short number returns raw" do
    assert_equal "123", masked_thai_mobile("123")
  end

  test "masked_thai_mobile formats 10 digit" do
    s = masked_thai_mobile("0812345678")
    assert_includes s, "(+66)"
    assert_includes s, "******"
  end
end
