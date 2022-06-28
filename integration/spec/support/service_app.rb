class ServiceApp < SitePrism::Page
  element :start_button, :button, 'Start'
  element :start_now_button, :button, 'Start Now'
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

  def load(expansion_or_html = {}, &block)
    puts "Visiting form: #{self.url}"
    super
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
end
