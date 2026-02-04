# Database Cleaner configuration for proper test isolation
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  # For non-system tests, use transaction strategy
  config.before(:each) do |example|
    if example.metadata[:type] == :system
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end

    DatabaseCleaner.start
  end

  # Use append_after to ensure this runs after Capybara's cleanup
  config.append_after(:each) do
    DatabaseCleaner.clean
  end
end
