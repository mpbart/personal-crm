$:.unshift File.expand_path('../../lib', __FILE__)
require_relative 'boot'

require 'rails/all'
require 'devise'
require 'awesome_print'
require 'pry'
require 'will_paginate'
require 'cocoon'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

module PersonalCrm
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.time_zone = 'America/Chicago'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
