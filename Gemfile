# encoding: utf-8
source 'https://rubygems.org'
gemspec name: 'train'

group :test do
  gem 'coveralls', require: false
  gem 'minitest', '~> 5.8'
  gem 'rake', '~> 10' # @todo bump this when we bump rubocop
  gem 'rubocop', '~> 0.36.0'
  gem 'simplecov', '~> 0.10'
  gem 'concurrent-ruby', '~> 1.0'
  gem 'pry-byebug'
  gem 'm'
  # This is not a true gem installation
  # (Gem::Specification.find_by_path('train-gem-fixture') will return nil)
  # but it's close enough to show the gempath handler can find a plugin
  # See test/unit/
  gem 'train-test-fixture', path: 'test/fixtures/plugins/train-test-fixture'
end

group :integration do
  gem 'berkshelf', '>= 6.3.4'
  gem 'test-kitchen', '>= 1.2.4'
  gem 'kitchen-vagrant'
  gem 'ed25519' # ed25519 ssh key support
  gem 'bcrypt_pbkdf' # ed25519 ssh key support
end

group :tools do
  gem 'pry', '~> 0.10'
  gem 'rb-readline'
  gem 'license_finder'
end
