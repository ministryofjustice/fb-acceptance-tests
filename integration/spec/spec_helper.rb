require 'capybara/rspec'
require 'selenium/webdriver'
require 'site_prism'
require 'fb/integration'
require 'dotenv'
Dotenv.load('tests.env')
require 'active_support/all'

if ENV['CI_MODE'].present?
  Dotenv.require_keys(
    'GOOGLE_REFRESH_TOKEN',
    'GOOGLE_CLIENT_ID',
    'GOOGLE_CLIENT_SECRET'
  )
end

RSpec.configure do |c|
  Capybara.register_driver :selenium do |app|
    chrome_options = Selenium::WebDriver::Chrome::Options.new.tap do |o|
      o.add_argument '--headless'
      o.add_argument '--no-sandbox'
    end
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_options)
  end
  Capybara.default_driver = :selenium

  Capybara.app_host = 'http://localhost:3003'
  c.include Capybara::DSL

  c.after do |example_group|
    if example_group.exception.present?
      puts "***************************************"
      puts page.text
      puts "***************************************"
    end
  end

  require File.join(File.dirname(__FILE__), 'support', 'service_app')
  require File.join(File.dirname(__FILE__), 'support', 'pages', 'features_email_app')
  Dir[
    File.expand_path(File.join(File.dirname(__FILE__), 'support', '**', '*.rb'))
  ].each { |f| require f }
end
