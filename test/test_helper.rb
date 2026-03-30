# frozen_string_literal: true

require_relative "../config/simplecov_bootstrap"

ENV["RAILS_ENV"] ||= "test"
ENV["OMISE_SECRET_KEY"] ||= "skey_test"
ENV["OMISE_PUBLIC_KEY"] ||= "pkey_test"
require_relative "../config/environment"
require "rails/test_help"

Rails.root.glob("test/support/**/*.rb").sort.each { |f| require f }
OmiseTestStubs.apply! if defined?(OmiseTestStubs)

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

    # Add more helper methods to be used for all tests here...
  end
end

class ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include Devise::Test::IntegrationHelpers
  include ModelTestHelpers
end

class ActiveJob::TestCase
  include ModelTestHelpers
end

class ActionView::TestCase
  include ModelTestHelpers
end
