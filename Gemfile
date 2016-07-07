source 'https://rubygems.org'

ruby '2.3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.4'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'rake', '~> 10.5'

gem 'dotenv-rails', github: 'bkeepers/dotenv', require: 'dotenv/rails-now'

if ENV['DEBUG_SERVER']
  gem 'graph_starter', path: '../graph_starter'
else
  gem 'graph_starter', git: 'https://github.com/neo4j-examples/graph_starter'
end

gem 'aws-sdk', '< 2.0'

gem 'puma'
gem 'unicorn-rails' if !ENV['DEBUG_SERVER']
gem 'unicorn-worker-killer'

gem 'faraday'

gem 'asciidoctor'
gem 'mathjax-rails'

gem 'rails-html-sanitizer'

gem 'devise-neo4j'
gem 'omniauth-twitter'
gem 'omniauth-github'

gem 'redis-rails'

gem 'rubocop'

gem 'rollbar', '~> 2.8.1'

gem 'aws-ses', '~> 0.6.0', require: 'aws/ses'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'pry'
  gem 'awesome_print'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'meta_request'
end

gem 'twitter'

gem 'parallel', require: false

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'capistrano-rails'
  gem 'capistrano3-unicorn'
  gem 'capistrano-rbenv'
  gem 'capistrano-bundler'

  gem 'stackprof'
end

group :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'vcr'
  gem 'webmock', require: false

  gem 'cucumber'
  gem 'rspec-expectations'
  gem 'capybara'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'sauce'
  gem 'sauce-connect'
end

group :production do
  gem 'rails_12factor'
  gem 'heroku-deflater'
  gem 'newrelic_rpm'
end
