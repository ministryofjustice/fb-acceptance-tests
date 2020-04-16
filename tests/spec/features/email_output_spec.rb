require 'capybara/rspec'
require 'spec_helper'
require 'httparty'
require 'mail'
require 'pdf-reader'
require 'cgi'
require 'csv'

class FeaturesEmailApp < SitePrism::Page
  set_url 'http://features-email-app:3000'

  element :start_button, :button, 'Start'
  element :first_name_field, :field, 'First name'
  element :last_name_field, :field, 'Last name'
  element :continue_button, :button, 'Continue'
  element :has_email_field, :radio_button, 'Yes', visible: false
  element :email_field, :field, 'Your email address'
  element :apples_field, :checkbox, 'Apples', visible: false
  element :pears_field, :checkbox, 'Pears', visible: false
  element :day_field, :field, 'Day'
  element :month_field, :field, 'Month'
  element :year_field, :field, 'Year'
  element :number_cats_field, :field, 'How many cats have chosen you?'
  element :cat_spy_field, :select, 'Is your cat watching you now?'
  element :autocomplete_field, '#page_autocomplete--autocomplete_autocomplete', visible: false
  element :cat_picture_field, :file_field, 'What does your cat look like?'
  element :confirm_upload_field, :radio_button, 'Yes, add this upload', visible: false
end

describe 'Filling out an Email output form' do
  let(:form) { FeaturesEmailApp.new }
  before :each do
    OutputRecorder.cleanup_recorded_requests
  end

  it 'sends an email with the submission in a PDF' do
    form.load
    form.start_button.click
    form.first_name_field.set('Form')
    form.last_name_field.set('Builders')
    continue

    form.has_email_field.choose
    continue

    form.email_field.set('form-builder-developers@digital.justice.gov.uk')
    continue

    # text
    fill_in 'cat_details', with: 'My cat is a fluffy killer'
    continue

    # checkbox
    form.apples_field.check
    form.pears_field.check
    continue

    # date
    form.day_field.set('12')
    form.month_field.set('11')
    form.year_field.set('2007')
    continue

    # number
    form.number_cats_field.set(28)
    continue

    # select
    form.cat_spy_field.select("I can't say (They can read)")
    continue

    # autocomplete
    form.autocomplete_field.set("California Spangled\n") # the new line "presses enter" on the selected option
    continue

    # upload
    attach_file("cat_picture[1]", 'spec/fixtures/files/hello_world.txt')
    continue

    # upload check
    form.confirm_upload_field.choose
    continue

    click_on 'Send complaint'

    expect(form.text).to include("You've sent us the answers about your cat!")

    # expected 4 emails because the SERVICE_OUTPUT contains 2 emails
    # 1 email (submission & attachment) for the first service output
    # 1 email (submission & attachment) to the second service output
    # 2 emails (CSV submission) to both on the Service Output
    #
    recorded_emails = OutputRecorder.wait_for_result(url: '/email', expected_requests: 4)

    recorded_emails[0..1].each do |email|
      attachments = parse_email(email).attachments
      pdf_answers = attachments.detect { |attachment| attachment.filename.include?('-answers.pdf') }
      file_upload = attachments.detect { |attachment| attachment.filename.include?('hello_world.txt') }

      assert_pdf_contents(pdf_answers)
      assert_file_upload(
        actual: file_upload,
        expected: File.read("spec/fixtures/files/hello_world.txt")
      )
    end

    assert_csv_contents(recorded_emails[2])
    assert_csv_contents(recorded_emails[3])
  end

  def continue
    form.continue_button.click
  end

  def parse_email(email)
    url_decoded_hash = CGI::parse(email)
    Mail.read_from_string(url_decoded_hash.fetch('raw_message'))
  end

  def assert_pdf_contents(attachment)
    pdf_path = '/tmp/submission.pdf'

    File.open(pdf_path, 'w') { |file| file.write(attachment.decoded) }
    result = PDF::Reader.new(pdf_path).pages.map { |page| page.text }.join(' ')

    p 'Asserting PDF contents'

    expect(result).to include('Email Output Service PDF Heading')

    # text
    expect(result).to include('Your name')
    expect(result).to match(/First name[\n\r\s]+Form/)
    expect(result).to match(/Last name[\n\r\s]+Builders/)

    # radio
    expect(result).to include('Can we contact you by')
    expect(result).to include('email?')
    expect(result).to include('Yes')

    # email
    expect(result).to include('Your email address')
    expect(result).to include('form-builder-developers@digital.justice.gov.uk')

    # textarea
    expect(result).to include('Your cat')
    expect(result).to include('My cat is a fluffy killer')

    # checkbox
    expect(result).to include('Your fruit')
    expect(result).to include('Choose your fruit')
    expect(result).to include('Apples')
    expect(result).to include('Pears')

    # date
    expect(result).to include('When did your cat choose')
    expect(result).to include('you?')
    expect(result).to include('12 November 2007')

    # number
    expect(result).to include('How many cats have chosen')
    expect(result).to include('you?')
    expect(result).to include('28')

    # select
    expect(result).to include('Is your cat watching you')
    expect(result).to include('now?')
    expect(result).to include("I can't say (They can read)")

    expect(result).to include('Cat breed')
    expect(result).to include('California Spangled')

    expect(result).to include('What does your cat look')
    expect(result).to include('like?')
    expect(result).to include('hello_world.txt (12B)')
  end

  def assert_csv_contents(email)
    path_to_file = '/tmp/submission.csv'

    parsed_message = parse_email(email)

    parsed_message.attachments.each do |attachment|
      File.open(path_to_file, 'w') { |file| file.write(attachment.decoded) }
      rows = CSV.read(path_to_file)

      p 'Asserting CSV contents'

      expect(rows[0]).to eql([
        'submission_id',
        'submission_at',
        'first_name',
        'last_name',
        'has_email',
        'email_address',
        'cat_details',
        'checkbox_apples',
        'checkbox_pears',
        'date',
        'number_cats',
        'cat_spy',
        'cat_breed',
        'cat_picture'
      ])

      expect(rows[1][0]).to match(/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/) # guid
      expect(rows[1][1]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z/) # iso timestamp
      expect(rows[1][2..-1]).to eql([
        'Form',
        'Builders',
        'yes',
        'form-builder-developers@digital.justice.gov.uk',
        'My cat is a fluffy killer',
        'Apples',
        'Pears',
        '2007-11-12',
        '28',
        'machine answer 3',
        'California Spangled',
        'data not available in CSV format'
      ])
    end
  end

  def assert_file_upload(actual:, expected:)
    expect(actual.decoded).to eq(expected)
  end
end
