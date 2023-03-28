class SaveAndReturnV2App < FeaturesEmailApp
  set_url "#{ENV['SAVE_AND_RETURN_V2_APP']}" % {
    user: ENV['NEW_RUNNER_ACCEPTANCE_TEST_USER'],
    password: ENV['NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD']
  }

  element :start_button, :button, 'Start now'
  element :question_1, :field, 'Question'
  element :save_and_return, :link, 'Save for later'
  element :email, :field, 'Email address'
  element :secret_answer, :field, 'The answer to your security question'
  element :secret_question_1, :radio_button, 'What is your mother\'s maiden name?', visible: false
  element :secret_question_2, :radio_button, 'What is the last name of your favourite teacher?', visible: false
  element :secret_question_3, :radio_button, 'What is the name of the hospital where you were born?', visible: false

  # element :change_optional_checkbox, :link, text: 'Your answer for Optional checkboxes (Optional)', visible: false
  # element :change_optional_file_upload, :link, text: 'Your answer for Optional file upload (Optional)', visible: false
  # element :remove_file, :link, text: 'Remove file'
  # element :change_first_name, :link, text: 'Your answer for First name', visible: false
  # element :change_last_name, :link, text: 'Your answer for Last name', visible: false
  # element :change_email, :link, text: 'Your answer for Your email address', visible: false
  # element :change_cat, :link, text: 'Your answer for Your cat', visible: false
  # element :change_upload, :link, text: 'Your answer for Upload a file', visible: false
  # element :change_autocomplete, :link, text: 'Where do you like to holiday?', visible: false
  # element :autocomplete_countries_field, :field, 'Where do you like to holiday?'

  def load(expansion_or_html = {}, &block)
    puts "Visiting form: #{ENV['SAVE_AND_RETURN_V2_APP'] % { user: '*****', password: '*****' }}"
    SitePrism::Page.instance_method(:load).bind(self).call
    self.wait_until_displayed
  end
end
