class FeaturesJsonSubmissionApiApp < FeaturesEmailApp
  set_url "#{ENV['JSON_SUBMISSION_API_V2_APP']}" % {
    user: ENV['NEW_RUNNER_ACCEPTANCE_TEST_USER'],
    password: ENV['NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD']
  }

  element :start_button, :button, 'Start now'
  element :continue_form, :link, 'Continue'
  element :question_1, :field, 'Answer to the Ultimate Question of Life, the Universe, and Everything'
end
