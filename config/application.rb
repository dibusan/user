require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OpenttScheduler
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Include all .rb files in <project>/lib folder
    # config.autoload_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('lib')


    # DEPRECATION WARNING: Time columns will become time zone aware in Rails 5.1. This
    # still causes `String`s to be parsed as if they were in `Time.zone`,
    #   and `Time`s to be converted to `Time.zone`.
    #
    #   To keep the old behavior, you must add the following to your initializer:
    #
    #         config.active_record.time_zone_aware_types = [:datetime]
    #
    # To use the new behavior, add the following:
    #
    #         config.active_record.time_zone_aware_types = [:datetime, :time]
    config.active_record.time_zone_aware_types = [:datetime, :time]
  end
end
