require File.expand_path('../boot', __FILE__)

require 'rails'
require 'logger'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
# require "active_record/railtie"
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require 'neo4j/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GraphStarter
  class Engine < ::Rails::Engine
    config.paperclip_defaults = {
      storage: :s3,
      s3_credentials: {
        bucket: ENV['S3_BUCKET_NAME'],
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      },
      s3_protocol: :https,
      styles: {medium: '300x300>', thumb: '50x50>'},
      url: ':s3_domain_url',
      path: '/:class/:attachment/:id_partition/:style/:filename'
    }
  end
end

module GraphgistPortal
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.eager_load_paths += [Rails.root.join('lib').to_s]

    config.assets.precompile += %w(
      jquery.datetimepicker.js
      jquery.datetimepicker.css

      graphgist-render.js
      graphgist-render.css
    )

    config.neo4j.pretty_logged_cypher_queries = true
    config.neo4j.record_timestamps = true

    config.action_mailer.delivery_method = :ses

    config.cache_store = :redis_store, ENV['REDIS_URL']
  end
end
