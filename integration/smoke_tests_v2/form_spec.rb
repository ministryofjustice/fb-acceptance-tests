require 'spec_helper'
require 'pdf-reader'
require 'csv'

class SmokeTestV2RunnerForm < ServiceApp
  set_url ENV.fetch('SMOKE_TEST_FORM_V2')

  element :start_button, :button, 'Start now'
  element :name_field, :field, 'Name'
  element :text_field, :field, 'Text Field'
  element :number_field, :field, 'Number Field'
  element :day_field, :field, 'Day'
  element :month_field, :field, 'Month'
  element :year_field, :field, 'Year'
  element :textarea_field, :field, 'Textarea Field'
  element :apples, :radio_button, 'Apples', visible: false
  element :another_text_field, :field, 'Text'
  element :another_number_field, :field, 'Number'
  element :postcode, :field, 'Text Field with Postcode'
  element :red, :checkbox, 'Red', visible: false

  def username
    ENV['SMOKE_TEST_USER']
  end

  def password
    ENV['SMOKE_TEST_PASSWORD']
  end
end

describe 'Smoke test' do
  let(:form) { SmokeTestV2RunnerForm.new }
  let(:generated_name) { "Saruman-#{SecureRandom.uuid}" }
  let(:pdf_path) { '/tmp/submission.pdf' }
  let(:csv_path) { '/tmp/submission.csv' }

  before { form.load }

  it 'makes a submission and send an email' do
    form.start_button.click
    form.name_field.set(generated_name)
    form.continue_button.click

    form.continue_button.click
    # Validations
    expect(form.text).to include('Enter an answer for "Text Field"')
    expect(form.text).to include('Enter an answer for "Number Field"')
    expect(form.text).to include('Enter an answer for "Date Field"')

    form.text_field.set('We must join with Him, Gandalf')
    form.number_field.set('2')
    form.day_field.set('10')
    form.month_field.set('10')
    form.year_field.set('2020')
    form.continue_button.click

    form.textarea_field.set('Time? What time do you think we have?')
    form.apples.choose
    form.another_text_field.set('The hour is later than you think')
    form.another_number_field.set('2')
    form.postcode.set('NW8 6CB')
    form.continue_button.click

    form.red.check
    form.continue_button.click

    attach_file('Upload a file', 'spec/fixtures/files/hello_world.txt')
    form.continue_button.click

    form.submit_button.click

    attachments = EmailAttachmentExtractor.find(
      id: generated_name,
      expected_emails: 1,
      find_criteria: :pdf_attachments
    )

    csv_attachments = EmailAttachmentExtractor.find(
      id: generated_name,
      expected_emails: 1,
      find_criteria: :csv_attachments
    )


    puts 'Verifying file upload'
    expect(attachments[:file_upload]).to eq(
      File.read('spec/fixtures/files/hello_world.txt')
    )
    puts 'Verifying the PDF answers'
    File.open(pdf_path, 'w') { |file| file.write(attachments[:pdf_answers]) }
    result = PDF::Reader.new(pdf_path).pages.map { |page| page.text }.join(' ')

    expect(result).to include(generated_name)
    expect(result).to include('We must join with Him, Gandalf')
    expect(result).to include('2')
    expect(result).to include('10')
    expect(result).to include('10')
    expect(result).to include('2020')
    expect(result).to include('Time? What time do you think we have?')
    expect(result).to include('Apples')
    expect(result).to include('The hour is later than you think')
    expect(result).to include('2')
    expect(result).to include('NW8 6CB')
    expect(result).to include('Red')
    expect(result).to include('hello_world.txt')

    puts 'Verifying the CSV answers'
    content = csv_attachments[:csvs].first || ''
    puts "CSV CONTENT: #{content}"
    File.open(csv_path, 'w') { |file| file.write(content) }
    rows = CSV.read(csv_path)
    answers = rows[1]

    expect(answers).to include(generated_name)
    expect(answers).to include('We must join with Him, Gandalf')
    expect(answers).to include('2')
    expect(answers).to include('10 October 2020')
    expect(answers).to include('Time? What time do you think we have?')
    expect(answers).to include('Apples')
    expect(answers).to include('The hour is later than you think')
    expect(answers).to include('2')
    expect(answers).to include('NW8 6CB')
    expect(answers).to include('Red')
    expect(answers).to include('hello_world.txt')
  end
end
