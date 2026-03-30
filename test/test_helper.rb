# frozen_string_literal: true

require_relative "../config/simplecov_bootstrap"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # SimpleCov + parallel tests need merged results; use one worker when measuring coverage.
    parallelize(workers: ENV["COVERAGE"] == "false" ? :number_of_processors : 1)

    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
