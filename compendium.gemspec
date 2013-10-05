# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'compendium/version'

Gem::Specification.new do |gem|
  gem.name          = "compendium"
  gem.version       = Compendium::VERSION
  gem.authors       = ["Daniel Vandersluis"]
  gem.email         = ["dvandersluis@selfmgmt.com"]
  gem.description   = %q{Ruby on Rails reporting framework}
  gem.summary       = %q{Ruby on Rails reporting framework}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'activesupport', '>= 3.0.0'
  gem.add_dependency 'rails', '>= 3.0.0'
  gem.add_development_dependency 'rspec', '~> 2.0'
end
