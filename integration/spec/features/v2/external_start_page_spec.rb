require 'spec_helper'

describe 'Page with external start page' do
  before :each do
    OutputRecorder.cleanup_recorded_requests if ENV['CI_MODE'].blank?
  end
  let(:form) { EternalStartPageApp.new }

  # use same username and password as new runner acceptance test
  let(:username) { ENV['NEW_RUNNER_ACCEPTANCE_TEST_USER'] }
  let(:password) { ENV['NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD'] }
  let(:q1_answer) { 'Hello' }

  before { form.load }
  # comment above line and uncomment below and export user and password ENV vars for local testing
  # before { visit "https://#{username}:#{password}@external-start-page-acceptance-test.dev.test.form.service.justice.gov.uk/" }

  it 'uses an external start page' do
    # bypasses start page
    expect(page.text).to include('First Question')
    # header link is set to the external start page
    expect(page).to have_link('external-start-page-acceptance-test', href: 'https://gov.uk')
    form.question_1.set(q1_answer)
    continue
    expect(page.text).to include('Check you answers')
    visit "https://#{username}:#{password}@external-start-page-acceptance-test.dev.test.form.service.justice.gov.uk/"
    sleep 1
    # bypasses start page on revisit
    expect(page.text).to include('First Question')
    # session and previous answer still present
    expect(page.text).to include(q1_answer)
  end
end