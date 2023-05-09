class SaveAndReturnV2App < FeaturesEmailApp
  set_url "#{ENV['SAVE_AND_RETURN_V2_APP']}" % {
    user: ENV['NEW_RUNNER_ACCEPTANCE_TEST_USER'],
    password: ENV['NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD']
  }

  element :start_button, :button, 'Start now'
  element :continue_form, :link, 'Continue'
  element :question_1, :field, 'Question'
  element :save_and_return, :button, 'Save for later'
  element :email, :field, 'Email address'
  element :secret_answer, :field, 'The answer to your security question'
  element :secret_question_1, :radio_button, 'What is your mother\'s maiden name?', visible: false
  element :secret_question_2, :radio_button, 'What is the last name of your favourite teacher?', visible: false
  element :secret_question_3, :radio_button, 'What is the name of the hospital where you were born?', visible: false
  element :email_confirmation, :field, 'Check your email address is correct'
  element :resume_secret_answer, :field, 'What is your mother\'s maiden name?'

  def load(expansion_or_html = {}, &block)
    puts "Visiting form: #{ENV['SAVE_AND_RETURN_V2_APP'] % { user: '*****', password: '*****' }}"
    SitePrism::Page.instance_method(:load).bind(self).call
    self.wait_until_displayed
  end
end
