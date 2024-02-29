class WelshLocaleApp < ServiceApp
  set_url ENV['WELSH_LOCALE_APP'] % {
    user: ENV['NEW_RUNNER_ACCEPTANCE_TEST_USER'],
    password: ENV['NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD']
  }

  element :accept_analytics_button, :button, 'Derbyn cwcis dadansoddol'
  element :reject_analytics_button, :button, 'Gwrthod cwcis dadansoddol'
  element :hide_cookie_message_button, :button, 'Cuddio’r neges hon'
  element :view_cookies_link, :link, 'Gweld cwcis'

  elements :footer_links, 'ul.govuk-footer__inline-list a'

  element :cy_start_now_button, :button, 'Dechrau nawr'
  element :cy_continue_button, :button, 'Parhau'
  element :cy_save_form_button, :button, 'Cadw at yn hwyrach ymlaen'
end
