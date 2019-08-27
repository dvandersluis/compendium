source 'https://rubygems.org'

# Specify your gem's dependencies in compendium.gemspec
gemspec

group :development do
  gem 'rubocop', '0.74'
  gem 'rubocop-rspec', '1.35'
  gem 'rubocop_defaults', git: 'https://github.com/dvandersluis/rubocop_defaults.git'
end

if RUBY_VERSION >= '2.4'
  gem 'json', '>= 1.8.3'
end
