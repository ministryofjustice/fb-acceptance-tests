require 'spec_helper'

describe 'Page with external start page' do
  before :each do
    OutputRecorder.cleanup_recorded_requests if ENV['CI_MODE'].blank?
  end

  let(:form) { ExternalStartPageApp.new }
  let(:q1_answer) { 'Hello' }
  let(:q1_title) { 'First question' }

  before { form.load }

  it 'uses an external start page' do
    # bypasses start page
    expect(page.text).to include(q1_title)
    # header link is set to the external start page
    expect(page).to have_link('external-start-page-acceptance-test', href: 'https://gov.uk')
    form.question_1.set(q1_answer)
    continue
    expect(page.text).to include('Check your answers')
    form.service_header_link.click
    sleep 1
    # bypasses start page on revisit
    expect(page.text).to include(q1_title)
    # session and previous answer still present
    expect(form.question_1.value).to include(q1_answer)
  end
end
