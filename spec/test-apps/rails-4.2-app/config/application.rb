require_relative 'boot'
require 'rails'
require 'active_record/railtie'

Bundler.require(*Rails.groups)

module Rails42App
  class Application < Rails::Application
    config.eager_load = false
  end
end
