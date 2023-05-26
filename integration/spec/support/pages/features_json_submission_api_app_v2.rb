class FeaturesJsonSubmissionApiApp < FeaturesEmailApp
  set_url "#{ENV['JSON_SUBMISSION_API_V2_APP']}" % {
    user: ENV['NEW_RUNNER_ACCEPTANCE_TEST_USER'],
    password: ENV['NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD']
  }

  element :start_button, :button, 'Start now'
  element :continue_form, :link, 'Continue'
  element :option_Bertha, :checkbox, 'Bertha Benz', visible: false
  element :option_Margaret, :checkbox, 'Margaret Wilcox', visible: false
  element :question, :field, 'Answer to the Ultimate Question of Life, the Universe, and Everything'
  element :proof, :field, 'Proof supporting your solution'
  element :day, :field, 'Day'
  element :month, :field, 'Month'
  element :year, :field, 'Year'
  element :option_None, :radio_button, 'None', visible: false
  element :option_Others, :radio_button, 'Others', visible: false
  element :attachment, :file_field, 'Attachement 1'
  element :attachment2, :file_field, 'Attachement 2'
end
