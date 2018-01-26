require 'compendium/engine/mount'

module Compendium
  if defined?(Rails)
    class Engine < ::Rails::Engine
    end
  end
end
