module Compendium
  CompendiumError = Class.new(StandardError)

  InvalidCommand = Class.new(CompendiumError)
  CannotRedefineQueryType = Class.new(CompendiumError)
end