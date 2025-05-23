require 'spec_helper'

describe 'Save and return' do
  let(:form) { SaveAndReturnV2App.new }
  let(:generated_name) { "FN-#{SecureRandom.uuid}" }
  let(:error_message) { 'There is a problem' }
  let(:q1_answer) { 'Hello' }
  let(:q2_answer) { 'Goodybe' }

  before { form.load }

  it 'saves progress and returns to a form' do
    form.start_now_button.click

    check_optional_text(page.text)
    form.question_1.set(q1_answer)
    continue
    sleep 1
    form.save_and_return.click
    form.email.set('email@')
    continue
    sleep 1
    check_validation_error_message('Enter an email address in the correct format, like name@example.com')
    form.email.set('fb-acceptance-tests@digital.justice.gov.uk')
    continue
    sleep 1
    check_validation_error_message('Enter an answer for "Secret question"')
    form.secret_question_1.choose
    form.secret_question_2.choose
    form.secret_question_3.choose
    continue
    sleep 1
    check_validation_error_message('Enter an answer for "Secret answer"')
    expect(page.text).to_not include('Enter an answer for "Secret question"')
    form.secret_answer.set('foo')
    form.secret_question_1.choose
    continue
    sleep 1
    # cancel then answer another question then save progress
    form.cancel_saving.click
    form.question_2.set(q2_answer)
    continue
    form.save_and_return.click
    sleep 1
    form.email.set('fb-acceptance-tests@digital.justice.gov.uk')
    form.secret_question_1.choose
    form.secret_answer.set('foo')
    continue
    sleep 1
    form.email_confirmation.set('fb-acceptance-')
    continue
    sleep 1
    check_validation_error_message('Enter an email address in the correct format, like name@example.com')
    sleep 1
    form.email_confirmation.set('fb-acceptance-tests@digital.justice.gov.uk')
    continue
    sleep 1
    check_optional_text(page.text)
    expect(page.text).to include('Your form has been saved')
    expect(page.text).to include('We have sent a one-off link to fb-acceptance-tests@digital.justice.gov.uk')

    form.reject.click
    # check session is destroyed
    expect(page.text).to include('This form has been saved for later')
    sleep 10
    # resume_progress_email = get_resume_email('save-and-return-v2-acceptance-test')
    # resume_link = extract_link_from_email(resume_progress_email)

    # visit resume_link

    # expect(page.text).to include('Continue with "save-and-return-v2-acceptance-test"')
    # form.resume_secret_answer.set('bar')
    # continue
    # sleep 1
    # check_validation_error_message('Your answer is incorrect. You have 2 attempts remaining.')
    # form.resume_secret_answer.set('')
    # sleep 1
    # form.resume_secret_answer.set('foo')
    # sleep 1
    # continue
    # sleep 1
    # expect(page.text).to include('You have successfully retrieved your saved information.')
    # expect(page.text).to include(q1_answer)
    # expect(page.text).to include(q2_answer)
    # form.continue_form.click
    # expect(page.text).to include('The Third Question')
    # sleep 1
    # visit resume_link

    # expect(page.text).to include('That link has already been used')
  end

  def get_resume_email(reference_number)
    find_save_and_return_email(id: reference_number, expect_emails: nil).select do |email|
      email.subject.include?('Your saved form - \'save-and-return-v2-acceptance-test\'')
    end.select do |email|
      DateTime.parse(email.raw.payload.headers.find { |h| h.name == 'Date' }&.value).to_date == DateTime.now.to_date
    end.sort_by do |email|
      DateTime.parse(email.raw.payload.headers.find { |h| h.name == 'Date' }&.value.split[4]).to_time.to_i
    end.last
  end

  # NOTE: using `parts[1]` because that is the html message
  # `parts[0]` is plain text and does not include html nor the link
  def extract_link_from_email(email)
    message_body = email.raw.payload.parts[0].parts[1].body.data
    uuid_regex = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/
    uuid = message_body.match(uuid_regex)
    host = "#{ENV['SAVE_AND_RETURN_V2_APP']}/return/#{uuid}"

    host
  end
end
