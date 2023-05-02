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
  let(:q1_answer) { 'Hello' }

  before { form.load }
  # comment above line and uncomment below and export user and password ENV vars for local testing
  # before { visit "https://#{username}:#{password}@save-and-return-v2-acceptance-test.dev.test.form.service.justice.gov.uk/" }

  it 'saves progress and returns to a form' do
    form.start_now_button.click

    check_optional_text(page.text)
    form.question_1.set(q1_answer)
    continue
    form.save_and_return.click
    form.email.set('email@')
    continue
    check_validation_error_message('Enter an email address in the correct format, like name@example.com')
    form.email.set('fb-acceptance-tests@digital.justice.gov.uk')
    continue
    check_validation_error_message("can't be blank")
    form.secret_question_1.choose
    form.secret_question_2.choose
    form.secret_question_3.choose
    continue
    check_validation_error_message("can't be blank")
    form.secret_answer.set('foo')
    form.secret_question_1.choose
    continue
    check_optional_text(page.text)
    form.email_confirmation.set('email@email.com')
    check_validation_error_message("Check your email address is correct")
    form.email_confirmation.set('fb-acceptance-tests@digital.justice.gov.uk')
    continue
    check_optional_text(page.text)
    expect(page.text).to include('Your form has been saved')
    expect(page.text).to include('We have sent a one-off link to fb-acceptance-tests@digital.justice.gov.uk')

    resume_progress_email = get_resume_email('save-and-return-v2-acceptance-test')
    resume_link = extract_link_from_email(resume_progress_email)
    
    visit resume_link

    expect(page.text).to include('Continue with "save-and-return-v2-acceptance-test"')
    form.resume_secret_answer.set('bar')
    continue
    check_validation_error_message('Your answer is incorrect. You have 3 attempts remaining.')
    form.resume_secret_answer.set('foo')
    continue
    # expect(page.text).to include('You have sucessfuly retrieved your saved information.')
    expect(page.text).to include(q1_answer)

    visit resume_link

    expect(page.text).to include('That link has already been used')
  end

  def get_resume_email(reference_number)
    find_save_and_return_email(id: reference_number, expect_emails: nil).select do |email|
      email.subject.include?('Resuming your application to')
    end.sort_by { |email| email.raw.payload.headers[18].value }.last
  end

  def extract_link_from_email(email)
    message_body = email.raw.payload.parts[0].parts[0].body.data
    uuid_regex = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/
    uuid = message_body.match(uuid_regex)
    host = "https://#{username}:#{password}@save-and-return-v2-acceptance-test.dev.test.form.service.justice.gov.uk/return/#{uuid}"

    host
  end
end
