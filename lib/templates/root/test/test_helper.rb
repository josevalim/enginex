# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

$:.unshift File.dirname(__FILE__)

Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = false
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }