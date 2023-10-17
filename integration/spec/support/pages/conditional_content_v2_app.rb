class ConditionalContentV2App < ServiceApp
  set_url "#{ENV['CONDITIONAL_CONTENT_V2_APP']}" % {
    user: ENV['NEW_RUNNER_ACCEPTANCE_TEST_USER'],
    password: ENV['NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD']
  }
end
