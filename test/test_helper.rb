# frozen_string_literal: true

require_relative "../config/simplecov_bootstrap"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

Rails.root.glob("test/support/**/*.rb").sort.each { |f| require f }

module ActiveSupport
  class TestCase
    include ModelTestHelpers

    # SimpleCov needs single process; parallel + fork + PostgreSQL can be flaky locally.
    # Set PARALLEL_WORKERS=4 (or :number_of_processors) to opt in to parallel runs.
    parallel_workers =
      if ENV["COVERAGE"] != "false"
        1
      elsif (w = ENV["PARALLEL_WORKERS"].to_s).present?
        w == "max" ? :number_of_processors : w.to_i
      else
        1
      end
    parallelize(workers: parallel_workers)

    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
