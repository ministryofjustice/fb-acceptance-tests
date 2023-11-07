require 'spec_helper'
require 'pdf-reader'
require 'csv'

class SmokeTestForm < ServiceApp
  set_url "#{ENV.fetch('SMOKE_TEST_FORM')}" % {
    user: ENV['SMOKE_TEST_USER'],
    password: ENV.fetch('SMOKE_TEST_PASSWORD')
  }

  element :name_field, :field, 'Name'
  element :text_field, :field, 'Text Field'
  element :number_field, :field, 'Number Field'
  element :day_field, :field, 'Day'
  element :month_field, :field, 'Month'
  element :year_field, :field, 'Year'
  element :textarea_field, :field, 'Textarea Field'
  element :checkboxes, :radio_button, 'Checkboxes', visible: false
  element :another_text_field, :field, 'Text'
  element :another_number_field, :field, 'Number'
  element :auto_complete_field, :field, 'Autocomplete Field'
  element :postcode, :field, 'Text Field with Postcode Regex'
  element :red, :checkbox, 'Red', visible: false
  element :add_upload, :radio_button, 'Yes, add this upload', visible: false

  # Service app will log the url which will contain user
  # and password.
  # Overwriting the signature method will
  # make the tests to not print anything.
  def load(expansion_or_html = {}, &block)
    puts "Visiting form: #{ENV['SMOKE_TEST_FORM'] % { user: '*****', password: '*****' }}"

    load_with_retry(app: self.class.name) do
      SitePrism::Page.instance_method(:load).bind(self).call
    end

    self.wait_until_displayed
  end
end

describe 'Smoke test' do
  let(:form) { SmokeTestForm.new }
  let(:username) { ENV.fetch('SMOKE_TEST_USER') }
  let(:password) { ENV.fetch('SMOKE_TEST_PASSWORD') }
  let(:generated_name) { "Saruman-#{SecureRandom.uuid}" }
  let(:pdf_path) { '/tmp/submission.pdf' }
  let(:csv_path) { '/tmp/submission.csv' }

  before { form.load }

  it 'makes a submission and send an email' do
    form.start_button.click
    form.name_field.set(generated_name)
    form.continue_button.click

    form.text_field.set('We must join with Him, Gandalf')
    form.number_field.set('2')
    form.day_field.set('10')
    form.month_field.set('10')
    form.year_field.set('2020')
    form.continue_button.click

    form.textarea_field.set('Time? What time do you think we have?')
    form.checkboxes.choose
    form.another_text_field.set('The hour is later than you think')
    form.another_number_field.set('2')
    form.auto_complete_field.set("Bravo\n")
    form.postcode.set('NW8 6CB')
    form.continue_button.click

    form.red.check
    form.continue_button.click

    attach_file('uploadfile_field[1]', 'spec/fixtures/files/hello_world.txt')
    form.continue_button.click

    form.add_upload.choose
    form.continue_button.click

    form.send_application_button.click
    attachments = EmailAttachmentExtractor.find(
      id: generated_name
    )

    puts 'Verifying file upload'
    expect(attachments[:file_upload]).to eq(
      File.read('spec/fixtures/files/hello_world.txt')
    )
    puts 'Verifying the answers'
    File.open(pdf_path, 'w') { |file| file.write(attachments[:pdf_answers]) }
    result = PDF::Reader.new(pdf_path).pages.map { |page| page.text }.join(' ')

    expect(result).to include(generated_name)
    expect(result).to include('We must join with Him, Gandalf')
    expect(result).to include('2')
    expect(result).to include('10')
    expect(result).to include('10')
    expect(result).to include('2020')
    expect(result).to include('Time? What time do you think we have?')
    expect(result).to include('The hour is later than you think')
    expect(result).to include('2')
    expect(result).to include("Bravo\n")
    expect(result).to include('NW8 6CB')
    expect(result).to include('hello_world.txt (12B)')

    puts 'Verifying CSV'
    expect(Array(attachments[:csvs]).size).to be(1)
    File.open(csv_path, 'w') { |file| file.write(attachments[:csvs].first) }
    rows = CSV.read(csv_path)

    expect(rows[0]).to match_array([
      'submission_id',
      'submission_at',
      'text_name',
      'text_field',
      'number_field',
      'date_field',
      'textarea_field',
      'autocomplete_field',
      'fieldset_text',
      'fieldset_number',
      'checkbox_red',
      'uploadfile_field',
      'postcode_field',
      'radio_fields'
    ])
    expect(rows[1]).to include(generated_name)
    expect(rows[1]).to include('We must join with Him, Gandalf')
    expect(rows[1]).to include('2')
    expect(rows[1]).to include('2020-10-10')
    expect(rows[1]).to include('Time? What time do you think we have?')
    expect(rows[1]).to include('The hour is later than you think')
    expect(rows[1]).to include('NW8 6CB')
    expect(rows[1]).to include('red')
    puts 'All good!'
  end
end
