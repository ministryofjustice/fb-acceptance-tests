class ExternalStartPageApp < FeaturesEmailApp
  set_url "#{ENV['EXTERNAL_START_PAGE_APP']}" % {
    user: ENV['NEW_RUNNER_ACCEPTANCE_TEST_USER'],
    password: ENV['NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD']
  }

  element :question_1, :field, 'First question'
end