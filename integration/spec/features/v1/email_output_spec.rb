require 'capybara/rspec'
require 'spec_helper'
require 'httparty'
require 'mail'
require 'pdf-reader'
require 'cgi'
require 'csv'

describe 'Filling out an Email output form' do
  let(:form) { FeaturesEmailApp.new }
  before :each do
    OutputRecorder.cleanup_recorded_requests if ENV['CI_MODE'].blank?
  end
  let(:generated_first_name) do
    SecureRandom.uuid
  end

  it 'sends an email with the submission in a PDF' do
    form.load
    form.start_button.click
    form.first_name_field.set(generated_first_name)
    form.last_name_field.set('Builders')
    continue

    form.has_email_field.choose
    continue

    form.email_field.set('fb-acceptance-tests@digital.justice.gov.uk')
    continue

    # text
    fill_in 'cat_details', with: 'My cat is a fluffy killer named £ % ~ ! @ # $ ^ * ( ) - _ = + [ ] | ; , . ?'
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
    attachments = find_attachments(
      pdf_filename: '-answers.pdf',
      user_attachment_filename: 'hello_world.txt'
    )

    assert_pdf_contents(attachments[:pdf_answers])
    assert_file_upload(
      actual: attachments[:file_upload],
      expected: File.read("spec/fixtures/files/hello_world.txt")
    )
    attachments[:csvs].each { |csv| assert_csv_contents(csv) }
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

    File.open(pdf_path, 'w') { |file| file.write(attachment) }
    result = PDF::Reader.new(pdf_path).pages.map { |page| page.text }.join(' ')

    p 'Asserting PDF contents'

    expect(result).to include('Email Output Service PDF Heading')

    # text
    expect(result).to include('Your name')
    expect(result).to match(/First name[\n\r\s]+#{generated_first_name}/)
    expect(result).to match(/Last name[\n\r\s]+Builders/)

    # radio
    expect(result).to include('Can we contact you by')
    expect(result).to include('email?')
    expect(result).to include('Yes')

    # email
    expect(result).to include('Your email address')
    expect(result).to include('fb-acceptance-tests@digital.justice.gov.uk')

    # textarea
    expect(result).to include('Your cat')
    expect(result).to match(/My cat is a fluffy killer named £ % ~ ! @ # $ ^ * ( ) - _ = + [ ] |[\n\r\s]; , ./)
    expect(result).to include('?')

    # checkbox
    expect(result).to include('Your fruit')
    expect(result).to include('Choose your fruit')
    expect(result).to include('Apples')
    expect(result).to include('Pears')

    # date
    expect(result).to include('When did your cat')
    expect(result).to include('choose you?')
    expect(result).to include('12 November 2007')

    # number
    expect(result).to include('How many cats have')
    expect(result).to include('chosen you?')
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

  def assert_csv_contents(attachment)
    path_to_file = '/tmp/submission.csv'

    File.open(path_to_file, 'w') { |file| file.write(attachment) }
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
      generated_first_name,
      'Builders',
      'yes',
      'fb-acceptance-tests@digital.justice.gov.uk',
      'My cat is a fluffy killer named £ % ~ ! @ # $ ^ * ( ) - _ = + [ ] | ; , . ?',
      'Apples',
      'Pears',
      '2007-11-12',
      '28',
      'machine answer 3',
      'California Spangled',
      'data not available in CSV format'
    ])
  end

  def find_attachments(pdf_filename:, user_attachment_filename:)
    if ENV['CI_MODE'].present?
      EmailAttachmentExtractor.find(id: generated_first_name)
    else
      all_attachments = {}

      emails = OutputRecorder.wait_for_result(url: '/email', expected_requests: 4)
      emails[0..1].each do |email|
        attachments = parse_email(email).attachments
        pdf_answers = attachments.detect do |attachment|
          attachment.filename.include?(pdf_filename)
        end
        file_upload = attachments.detect do |attachment|
          attachment.filename.include?(user_attachment_filename)
        end

        all_attachments[:pdf_answers] = pdf_answers.decoded
        all_attachments[:file_upload] = file_upload.decoded
      end

      all_attachments[:csvs] = emails[2..3].map do |email|
        parse_email(email).attachments.map(&:decoded)
      end.flatten

      all_attachments
    end
  end

  def assert_file_upload(actual:, expected:)
    expect(actual).to eq(expected)
  end
end
