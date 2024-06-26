class ServiceApp < SitePrism::Page
  element :start_button, :button, 'Start'
  element :start_now_button, :button, 'Start now'
  element :continue_button, :button, 'Continue'
  elements :summaries, 'dl .govuk-summary-list__value'
  elements :headings, '.govuk-heading-xl'
  elements :change_links, '.govuk-summary-list__actions a.govuk-link'
  element :send_application_button, :button, 'Accept and send application'
  element :submit_button, :button, 'Submit'
  element :confirmation_header, 'h1.govuk-panel__title'
  element :accept_analytics, :button, 'Accept analytics cookies'
  element :reject_analytics, :button, 'Reject analytics cookies'
  element :hide_cookie_message, :button, 'Hide this message'
  element :service_header_link, 'a.govuk-header__service-name'

  # Elements related to the auth sign in page
  element :auth_username, '#auth-form-username-field'
  element :auth_password, '#auth-form-password-field'
  element :sign_in_button, 'button[type="submit"].govuk-button'

  def load(expansion_or_html = {}, &block)
    puts "Visiting form: #{self.url}"
    load_with_retry(app: self.class.name) { super }
    authenticate
  end

  def all_headings
    headings.map(&:text)
  end

  def check_your_answers
    'Check your answers'
  end

  def in_summaries_page?
    all_headings.include?(check_your_answers)
  end

  def load_with_retry(app:, max_retries: 3, &block)
    retry_count = 0

    begin
      retry_count += 1
      block.call
    rescue Net::OpenTimeout, Net::ReadTimeout
      puts "Retrying #{app} load... Attempts: #{retry_count}/#{max_retries}"
      retry if retry_count < max_retries
    end
  end

  def authenticate
    puts "Authenticating with username and password"
    auth_username.set(username)
    auth_password.set(password)
    sign_in_button.click
  end

  def username
    ENV['NEW_RUNNER_ACCEPTANCE_TEST_USER']
  end

  def password
    ENV['NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD']
  end
end
