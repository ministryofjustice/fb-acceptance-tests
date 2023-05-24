require 'spec_helper'

describe 'API Submission' do
  before :each do
    OutputRecorder.cleanup_recorded_requests if ENV['CI_MODE'].blank?
  end

  let(:form) { FeaturesJsonSubmissionApiApp.new }
  let(:username) { ENV['NEW_RUNNER_ACCEPTANCE_TEST_USER'] }
  let(:password) { ENV['NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD'] }
  let(:generated_name) { "FN-#{SecureRandom.uuid}" }
  let(:error_message) { 'There is a problem' }

  before { form.load }
  # comment above line and uncomment below and export user and password ENV vars for local testing
  # before { visit "https://#{username}:#{password}@new-runner-acceptance-tests.dev.test.form.service.justice.gov.uk" }

  it 'sends an API submission' do
    form.start_now_button.click
    check_optional_text(page.text)
    form.question_1.set('42')
    continue

  end
end
