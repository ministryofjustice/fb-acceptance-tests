require 'spec_helper'

describe 'Save and return' do
  before :each do
    OutputRecorder.cleanup_recorded_requests if ENV['CI_MODE'].blank?
  end
  let(:form) { SaveAndReturnV2App.new }
  # use same username and password as new runner acceptance test 
  let(:username) { ENV['NEW_RUNNER_ACCEPTANCE_TEST_USER'] }
  let(:password) { ENV['NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD'] }
  let(:generated_name) { "FN-#{SecureRandom.uuid}" }
  let(:error_message) { 'There is a problem' }

  before { form.load }
  # comment above line and uncomment below and export user and password ENV vars for local testing
  # before { visit "https://#{username}:#{password}@save-and-return-v2-acceptance-test.dev.test.form.service.justice.gov.uk/" }

  it 'saves progress and returns to a form' do
    form.start_now_button.click

    check_optional_text(page.text)
    form.question_1.set('hello')
    continue
    form.save_and_return.click
    form.email.set('email@cool.com')
    form.secret_question_1.choose
    form.secret_question_2.choose
    form.secret_question_3.choose
    form.secret_answer.set('foo')
  end
end
