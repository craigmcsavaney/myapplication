Myapplication::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  # deprecated in rails 4.0:
  # config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # deprecated in rails 4.0:
  #config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  # config.assets.compress = false <- deprecated for Rails 4

  # Expands the lines which load the assets
  config.assets.debug = true

  config.assets.raise_production_errors = true

  # Added by Craig to prevent asset caching
  config.assets.cache_store = :null_store
  config.sass.cache = false

  # Added by Craig based on Devise configuration guidance:
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {:address => 'localhost', :port => '1025'}

  # added by craig as part of rails 4.0 upgrade:
  config.eager_load = false
  
  # following is configuration to send development emails via Gmail
  # config.action_mailer.smtp_settings = {
  #   address:              'smtp.gmail.com',
  #   port:                 '587',
  #   domain:               'causebutton.com',
  #   user_name:            'craig@causebutton.com',
  #   password:             'USna21412',
  #   authentication:       :login,
  #   enable_starttls_auto: true  }
end
