# frozen_string_literal: true

# Loaded before Rails from test/test_helper.rb or spec/simplecov_setup.rb.
# Set COVERAGE=false to skip.
return if ENV["COVERAGE"] == "false"

require "simplecov"

SimpleCov.start "rails" do
  command_name ENV["SIMPLECOV_COMMAND_NAME"] || (caller.any? { |l| l.include?("test_helper") } ? "Minitest" : "RSpec")

  enable_coverage :branch if ENV["COVERAGE_BRANCH"] == "1"

  add_filter "/spec/"
  add_filter "/test/"
  add_filter "/bin/"
  add_filter "/db/"
  add_filter "/config/"
  add_filter "/vendor/"
  add_filter "/node_modules/"
  add_filter "app/mailers/"
  add_filter "app/jobs/"
  add_filter "app/inputs/"

  root = File.expand_path("..", __dir__)
  add_group "Components", "app/components" if Dir.exist?("#{root}/app/components")
  add_group "Services", "app/services" if Dir.exist?("#{root}/app/services")
  add_group "Policies", "app/policies" if Dir.exist?("#{root}/app/policies")

  # minimum_coverage line: 80, branch: 50 if ENV["CI"]
end
