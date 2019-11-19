require 'capybara/rspec'
require 'spec_helper'
require 'httparty'
require 'mail'
require 'pdf-reader'
require 'cgi'

describe 'Filling out an Email output form' do
  before :each do
    OutputRecorder.cleanup_recorded_requests
  end

  it 'sends an email with the submission in a PDF' do
    visit 'http://runner-app:3000'
    click_on 'Start'

    # text
    fill_in 'First name', with: 'Bob'
    fill_in 'Last name', with: 'Smith'
    continue

    # radio
    choose 'has-email', option: 'yes', visible: false
    continue

    # email
    fill_in 'Your email address', with: 'bob.smith@digital.justice.gov.uk'
    continue

    # text
    fill_in 'complaint_details', with: 'Foo bar baz'
    continue

    # checkbox
    check 'Apples', visible: false
    continue

    # date
    fill_in 'COMPOSITE.date-day', with: '12'
    fill_in 'COMPOSITE.date-month', with: '11'
    fill_in 'COMPOSITE.date-year', with: '2007'
    continue

    # number
    fill_in 'number_cats', with: 28
    continue

    # select
    select "I can't say (They can read)", from: 'cat_spy'
    continue

    # autocomplete
    fill_in 'page_autocomplete--autocomplete_autocomplete', with: "California Spangled\n" # the new line "presses enter" on the selected option
    continue

    # upload
    attach_file("upload[1]", 'spec/fixtures/files/hello_world.txt')
    continue

    click_on 'Send complaint'

    recorded_emails = OutputRecorder.wait_for_result(url: '/email', expected_requests: 2)
    assert_pdf_contents recorded_emails[0]
    assert_file_upload(
        actual: recorded_emails[1],
        expected: File.read("spec/fixtures/files/hello_world.txt")
    )
  end

  def continue
    click_on 'Continue'
  end

  def parse_email(email)
    url_decoded_hash = CGI::parse(email)
    Mail.read_from_string(url_decoded_hash.fetch('raw_message'))
  end

  def assert_pdf_contents(pdf_email)
    pdf_path = '/tmp/submission.pdf'

    parsed_message = parse_email(pdf_email)

    parsed_message.attachments.each do |attachment|
      File.open(pdf_path, 'w') { |file| file.write(attachment.decoded) }
      result = PDF::Reader.new(pdf_path).pages.map { |page| page.text }.join(' ')

      p 'Email Received.  Asserting PDF contents'
      expect(result).to include('This is a custom PDF Heading')
      # text
      expect(result).to include('Your name')
      expect(result).to match(/First name[\n\r\s]+Bob/)
      expect(result).to match(/Last name[\n\r\s]+Smith/)

      # radio
      expect(result).to include('Can we contact you by')
      expect(result).to include('email?')
      expect(result).to include('Yes')

      # email
      expect(result).to match(/Your email address[\n\r\s]+bob.smith@digital.justice.gov.uk/)

      # textarea
      expect(result).to include('Please tell us about your')
      expect(result).to include('cat')
      expect(result).to include('Foo bar baz')

      expect(result).to include('Some Heading')
      # checkbox
      expect(result).to match(/Best Legend[\n\r\s]+Apples/)

      # date
      expect(result).to include('When did the cat choose')
      expect(result).to include('you?')
      expect(result).to include('12 November 2007')

      # number
      expect(result).to match(/How many cats\?[\n\r\s]+28/)

      # select
      expect(result).to include('Is your cat watching you')
      expect(result).to include('now?')
      expect(result).to include("I can't say (They can read)")

      expect(result).to include('Cat Breed')
      expect(result).to include('California Spangled')

      expect(result).to match(/Upload documents[\n\r\s]+hello_world.txt \(12B\)/)
    end
  end

  def assert_file_upload(actual:, expected:)
    attachments = parse_email(actual).attachments
    expect(attachments.size).to eq(1)
    expect(attachments.first.decoded).to eq(expected)
  end
end
