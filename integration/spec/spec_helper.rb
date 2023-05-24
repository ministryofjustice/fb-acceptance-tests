require 'capybara/rspec'
require 'selenium/webdriver'
require 'site_prism'
require 'fb/integration'
require 'dotenv'
Dotenv.load('tests.env')
require 'active_support/all'
require 'httparty'
require 'jwe'
require 'open-uri'

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
      o.add_argument '--disable-dev-shm-usage'
    end
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.read_timeout = 120
    client.open_timeout = 120
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_options, http_client: client)
  end
  Capybara.default_driver = :selenium
  Capybara.default_max_wait_time = 15

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

OPTIONAL_TEXT = [
  '[Optional section heading]',
  '[Optional lede paragraph]',
  '[Optional content]',
  '[Optional hint text]'
]

def check_optional_text(text)
  OPTIONAL_TEXT.each { |optional| expect(text).not_to include(optional) }
end

def check_error_message(text, fields)
  expect(page.text).to include(error_message)
  fields.each { |field| expect(text).to include("Enter an answer for \"#{field}\"")}
end

def check_validation_error_message(error)
  expect(page.text).to include(error)
end

def continue
  form.continue_button.click
end

def find_email_by_subject(id:)
  if ENV['CI_MODE'].present?
    EmailAttachmentExtractor.find(
      id: id,
      expected_emails: 3,
      find_criteria: :subject,
      include_whole_email: true
    )
  else
    {}
  end
end

def find_save_and_return_email(id:, expect_emails:)
  if ENV['CI_MODE'].present?
    EmailAttachmentExtractor.find(
      id: id,
      expected_emails: expect_emails,
      find_criteria: :subject,
      include_whole_email: true,
      return_all: true,
    )
  else
    {}
  end
end

def find_pdf_attachments(id:, expected_emails:)
  if ENV['CI_MODE'].present?
    EmailAttachmentExtractor.find(
      id: id,
      expected_emails: expected_emails,
      find_criteria: :pdf_attachments
    )
  else
    {}
  end
end

def find_csv_attachments(id:)
  if ENV['CI_MODE'].present?
    EmailAttachmentExtractor.find(
      id: id,
      expected_emails: 1,
      find_criteria: :csv_attachments
    )
  else
    {}
  end
end

def wait_for_request
  submission_path = "#{base_adapter_domain}/submission"
  tries = 0
  max_tries = 20

  until tries > max_tries
    puts "GET #{submission_path}"
    response = HTTParty.get(submission_path, **{ open_timeout: 10, read_timeout: 5 })

    if response.code == 200
      break
    else
      sleep 3
      tries += 1
    end
  end

  if tries == max_tries || response.code != 200
    raise "Base adapter didn't receive the submission: Adapter response: '#{response.body}'"
  else
    JSON.parse(
      response.body,
      symbolize_names: true
    )
  end
end

def delete_adapter_submissions
  HTTParty.delete(
    "#{base_adapter_domain}/submissions",
    **{ open_timeout: 10, read_timeout: 10 }
  )
end

def base_adapter_domain
  ENV.fetch('FORM_BUILDER_BASE_ADAPTER_ENDPOINT')
end
