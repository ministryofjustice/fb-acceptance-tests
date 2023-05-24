require 'capybara/rspec'
require 'spec_helper'
require 'support/helpers/json_helper'

describe 'JSON Output' do
  let(:form) { FeaturesJSONApp.new }

  before { delete_adapter_submissions }
  after { delete_adapter_submissions }

  it 'sends the JSON payload to the specified endpoint' do
    form.load
    form.start_button.click

    form.first_name_field.set('Form')
    form.last_name_field.set('Builders')
    continue

    form.has_email_field.choose
    continue

    form.email_field.set('form-builder-developers@digital.justice.gov.uk')
    continue

    fill_in 'cat_details', with: 'My cat is a fluffy killer'
    continue

    form.apples_field.check
    continue

    form.day_field.set('12')
    form.month_field.set('11')
    form.year_field.set('2007')
    continue

    form.number_cats_field.set(28)
    continue

    form.cat_spy_field.select("I can't say (They can read)")
    continue

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

    result = wait_for_request

    submission_answers_without_upload =
      result[:submissionAnswers].reject { |k, _| k == :cat_picture }

    uploads = result[:submissionAnswers][:cat_picture]
    upload = result[:submissionAnswers][:cat_picture][0]

    ## For running locally or in the CI
    expect(result[:serviceSlug]).to eq('slug').or eq('acceptance-tests-json-output')

    expect(submission_answers_without_upload).to eql(
      first_name: 'Form',
      last_name: 'Builders',
      has_email: 'yes',
      email_address: 'form-builder-developers@digital.justice.gov.uk',
      cat_details: 'My cat is a fluffy killer',
      date: '2007-11-12',
      number_cats: 28,
      cat_spy: 'machine answer 3',
      cat_breed: 'California Spangled',
      checkbox_apples: 'Apples'
    )

    expect(uploads.size).to eql(1)

    expect(Time.at(upload[:date])).to be_within(60.minutes).of(4.weeks.from_now)
    expect(upload[:destination]).to eql('/tmp/uploads')
    expect(upload[:encoding]).to eql('7bit')
    expect(upload[:fieldname]).to eql('cat_picture[1]')
    expect(upload[:filename].size).to be > 0
    expect(upload[:fingerprint]).to eql('28d-a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447')
    expect(upload[:maxSize]).to eql(5_242_880)
    expect(upload[:mimetype]).to eql('text/plain')
    expect(upload[:originalname]).to eql('hello_world.txt')
    expect(upload[:path]).to match(%r{/tmp/uploads/\S{32}})
    expect(upload[:size]).to eql(12)
    expect(upload[:type]).to eql('text/plain')
    expect(upload[:url]).to match(
      %r{/service/(slug|acceptance-tests-json-output)/user/\S{36}/28d-\S{64}}
    )
    expect(upload[:uuid]).to match(/\S{36}/)

    expect(result[:attachments].size).to eql(1)
    expect(result[:attachments][0][:encryption_iv].size).to eql(24)
    expect(result[:attachments][0][:encryption_key].size).to eql(44)
    expect(result[:attachments][0][:filename]).to eql('hello_world.txt')
    expect(result[:attachments][0][:mimetype]).to eql('text/plain')

    file_contents = URI.open(result[:attachments][0][:url], 'rb').read

    crypto = Cryptography.new(
      encryption_key: Base64.strict_decode64(result[:attachments][0][:encryption_key]),
      encryption_iv: Base64.strict_decode64(result[:attachments][0][:encryption_iv])
    )

    decrypted_file_contents = crypto.decrypt(file: file_contents)

    expect(decrypted_file_contents).to eql("hello world\n")

    expect(result).to have_key(:submissionId)
  end

  def continue
    click_on 'Continue'
  end
end
