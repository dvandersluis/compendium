module Compendium
  CompendiumError = Class.new(StandardError)

  module Queries
    InvalidCommand = Class.new(CompendiumError)
    CannotRedefineType = Class.new(CompendiumError)
  end
end
