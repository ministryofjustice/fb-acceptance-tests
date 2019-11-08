require 'capybara/rspec'
require 'spec_helper'
require 'httparty'
require 'mail'
require 'pdf-reader'

describe 'Filling out an Email output form' do
  it 'sends an email with the submission in a PDF' do
    visit 'http://runner-app-email:3000'

    click_on 'Start'
    fill_in 'First name', with: 'Bob'
    fill_in 'Last name', with: 'Smith'
    continue
    choose 'has-email', option: 'yes', visible: false
    continue
    fill_in 'Your email address', with: 'bob.smith@digital.justice.gov.uk'
    continue
    fill_in 'complaint_details', with: 'Foo bar baz'
    continue
    check 'Apples', visible: false
    continue

    fill_in 'COMPOSITE.date-day', with: '12'
    fill_in 'COMPOSITE.date-month', with: '11'
    fill_in 'COMPOSITE.date-year', with: '2007'
    continue

    fill_in 'number_cats', with: 28
    continue

    select "I can't say (They can read)", :from => "cat_spy"
    continue

    click_on 'Send complaint'

    wait_for_pdf_to_be_generated
    assert_pdf_contents
  end

  def continue
    click_on 'Continue'
  end

  def wait_for_pdf_to_be_generated(tries = 0, max_tries = 10)
    until HTTParty.get(ENV.fetch('EMAIL_ENDPOINT')).success?
      p 'waiting for PDF to be generated'
      fail 'PDF assertion timeout' if tries >= max_tries
      tries += 1
      sleep 2
    end
  end

  def assert_pdf_contents
    pdf_path = '/tmp/submission.pdf'

    response = HTTParty.get(ENV.fetch('EMAIL_ENDPOINT'))
    parsed_message = Mail.read_from_string(response.parsed_response['raw_message'])

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
    end
  end
end
