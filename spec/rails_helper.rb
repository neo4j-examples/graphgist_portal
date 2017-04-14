# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'


if ENV['CI']
  Sauce.config do |config|
    # config['record-video'] = false
    # config['record-screenshots'] = false
    bin = ENV['CI'] ? 'sc_linux' : 'sc_mac'
    config[:sauce_connect_4_executable] = Rails.root.join('bin', bin)
    config[:start_tunnel] = true
    config[:start_local_application] = false
  end
end

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# RSpec helpers for deleting data from Neo4j
module DeleteDbHelpers
  def delete_dbs
    Neo4j::Session.current.query('MATCH (n) DETACH DELETE n')
    User.delete_all
  end
end

# Helpers for testing API endpoints
module ApiHelper
  def json_response_body
    @json_response_body ||= JSON.parse(response.body, symbolize_names: true)
  end
end

RSpec.configure(&:infer_spec_type_from_file_location!)

RSpec.configure do |config|
  config.include DeleteDbHelpers
  config.include ApiHelper
end
