class ConditionalContentV2App < ServiceApp
  set_url "#{ENV['CONDITIONAL_CONTENT_V2_APP']}" % {
    user: ENV['NEW_RUNNER_ACCEPTANCE_TEST_USER'],
    password: ENV['NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD']
  }

  element :checkbox_1, :checkbox, 'Option 1', visible: false
  element :checkbox_2, :checkbox, 'Option 2', visible: false
  element :checkbox_O, :checkbox, 'Option', visible: false
  element :radio_a, :radio_button, 'a', visible: false
  element :radio_b, :radio_button, 'b', visible: false
  element :back, :link, text: 'Back', visible: false
end
