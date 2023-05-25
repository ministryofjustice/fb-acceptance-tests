require 'spec_helper'
require 'httparty'
require 'jwe'
require 'open-uri'

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
    attach_file("Hello", 'spec/fixtures/files/hello_world.txt')
    continue
    attach_file("Goodbye", 'spec/fixtures/files/goodbye_world.txt')
    continue
    form.submit_button.click

    expect(page.text).to include('Application complete')

    result = wait_for_request

    expect(result[:serviceSlug]).to eq('json-acceptance-test')
    expect(result[:ultimate-question_number_1]).to eq('42')
    expect(result[:attachment_upload_1]).to eq("Hello")
    expect(result[:attachment2_upload_1]).to eq("Goodbye")
    expect(result[:attachments].size).to eql(2)
  end

  def wait_for_request
    submission_path = "#{base_adapter_domain}/submission"
    tries = 0
    max_tries = 20

    until tries > max_tries
      puts "GET #{submission_path}"
      response = HTTParty.get(submission_path, **{ open_timeout: 10, read_timeout: 5 })

      if response.code == 200
        break
      else
        sleep 3
        tries += 1
      end
    end

    if tries == max_tries || response.code != 200
      raise "Base adapter didn't receive the submission: Adapter response: '#{response.body}'"
    else
      JSON.parse(
        response.body,
        symbolize_names: true
      )
    end
  end

  def delete_adapter_submissions
    HTTParty.delete(
      "#{base_adapter_domain}/submissions",
      **{ open_timeout: 10, read_timeout: 10 }
    )
  end

  def base_adapter_domain
    ENV.fetch('FORM_BUILDER_BASE_ADAPTER_ENDPOINT')
  end
end
