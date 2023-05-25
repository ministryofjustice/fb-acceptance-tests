class FeaturesJsonSubmissionApiApp < FeaturesEmailApp
  set_url "#{ENV['JSON_SUBMISSION_API_V2_APP']}" % {
    user: ENV['NEW_RUNNER_ACCEPTANCE_TEST_USER'],
    password: ENV['NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD']
  }

  element :start_button, :button, 'Start now'
  element :continue_form, :link, 'Continue'
  element :question, :field, 'Answer to the Ultimate Question of Life, the Universe, and Everything'
  element :attachment, :file_field, 'Attachement 1'
  element :attachment2, :file_field, 'Attachement 2'
end
