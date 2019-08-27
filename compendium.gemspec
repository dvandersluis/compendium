lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'compendium/version'

Gem::Specification.new do |gem|
  gem.name          = 'compendium'
  gem.version       = Compendium::VERSION
  gem.authors       = ['Daniel Vandersluis']
  gem.email         = ['daniel.vandersluis@gmail.com']
  gem.description   = 'Ruby on Rails reporting framework'
  gem.summary       = 'Ruby on Rails reporting framework'
  gem.homepage      = 'https://github.com/dvandersluis/compendium'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'collection_of', '1.0.6'
  gem.add_dependency 'compass-rails', '>= 1.0.0'
  gem.add_dependency 'inheritable_attr', '>= 1.0.0'
  gem.add_dependency 'rails', '>= 3.0.0'
  gem.add_dependency 'sass-rails', '>= 3.0.0'

  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake', '> 11.0.1'
  gem.add_development_dependency 'rspec', '~> 3.8.0'
  gem.add_development_dependency 'rubocop', '0.74'
  gem.add_development_dependency 'rubocop-rspec', '1.35'
end
