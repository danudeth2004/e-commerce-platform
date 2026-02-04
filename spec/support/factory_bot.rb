RSpec.configure do |config|
  # Include Factory Bot syntax methods
  config.include FactoryBot::Syntax::Methods

  # Ensure FactoryBot creates records that persist across database connections
  FactoryBot.use_parent_strategy = false
end
