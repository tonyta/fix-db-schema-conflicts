require_relative 'boot'
require 'rails'
require 'active_record/railtie'

Bundler.require(*Rails.groups)

module Rails51App
  class Application < Rails::Application
    config.load_defaults 5.1
    config.eager_load = false
  end
end
