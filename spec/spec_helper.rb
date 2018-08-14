require 'bundler/setup'
require 'compendium'
require 'pry'

RSpec.configure do |config|
  config.filter_run_when_matching(:focus)
  config.disable_monkey_patching!
  config.example_status_persistence_file_path = '.rspec_status'

  config.order = :random
  Kernel.srand(config.seed)

  config.mock_with :rspec do |mocks|
    mocks.yield_receiver_to_any_instance_implementation_blocks = true
    mocks.verify_partial_doubles = true
  end
end

require 'compendium'
