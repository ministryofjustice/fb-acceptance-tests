require 'pdf-reader'
require 'csv'

describe 'New Runner' do
  let(:form) { NewRunnerApp.new }
  let(:generated_name) { "FN-#{SecureRandom.uuid}" }
  let(:error_message) { 'There is a problem' }

  before { form.load }

  it 'sends an email with the submission in a PDF and a CSV' do
    form.start_now_button.click

    check_optional_text(page.text)
    continue
    check_error_message(page.text, ['First name', 'Last name'])
    form.first_name_field.set('Po')
    continue
    check_validation_error_message('Your answer for "First name" must be 3 characters or more')
    form.first_name_field.set('NaN' * 50)
    continue
    check_validation_error_message('Your answer for "First name" must be 50 characters or fewer')
    form.first_name_field.set('Stormtrooper')
    form.last_name_field.set(generated_name)
    continue

    check_optional_text(page.text)
    continue
    check_error_message(page.text, ['Your email address'])
    form.email_field.set('fb-acceptance-tests+confirmation@digital.justice.gov.uk')
    expect(page.text).to include('We will use this address to')
    continue

    # textarea
    check_optional_text(page.text)
    continue
    check_error_message(page.text, ['Your cat'])
    fill_in 'Your cat',
      with: 'Not long enough'
    continue
    check_validation_error_message('Your answer for "Your cat" must be 5 words or more')
    fill_in 'Your cat',
      with: 'Petrichor ' * 100
    continue
    check_validation_error_message('Your answer for "Your cat" must be 75 words or fewer')
    fill_in 'Your cat',
      with: 'My cat is a fluffy killer £ % ~ ! @ # $ ^ * ( ) - _ = + [ ] | ; , . ?'
    continue

    # optional fields
    check_optional_text(page.text)
    form.find(:css, '#optional-questions_checkboxes_1').check('Celery', visible: false)
    continue

    expect(page.text).not_to include(error_message)

    # checkbox
    check_optional_text(page.text)
    continue
    check_error_message(page.text, [form.find('h1').text])
    form.apples_field.check
    form.pears_field.check
    continue

    # date
    check_optional_text(page.text)
    continue
    check_error_message(page.text, [form.find('h1').text])
    form.day_field.set('12')
    form.month_field.set('11')
    form.year_field.set('not a valid year')
    continue
    check_validation_error_message('Enter a valid date for "When did your cat choose you?"')
    form.year_field.set('1999')
    continue
    check_validation_error_message('Your answer for "When did your cat choose you?" must be 01 01 2001 or later')
    form.year_field.set('2050')
    continue
    check_validation_error_message('Your answer for "When did your cat choose you?" must be 01 01 2022 or earlier')
    form.year_field.set('2007')
    continue

    # number
    check_optional_text(page.text)
    continue
    check_error_message(page.text, [form.find('h1').text])
    form.number_cats_field.set('i am not a number')
    continue
    check_validation_error_message('Enter a number for "How many cats have chosen you?"')
    form.number_cats_field.set(1)
    continue
    check_validation_error_message('Your answer for "How many cats have chosen you?" must be 3 or higher')
    form.number_cats_field.set(28)
    continue
    check_validation_error_message('Your answer for "How many cats have chosen you?" must be 10 or lower')
    form.number_cats_field.set(5)
    continue

    # radio
    check_optional_text(page.text)
    continue
    sleep 2
    check_error_message(page.text, [form.find('h1').text])
    form.yes_field.choose
    continue

    # attach file
    check_optional_text(page.text)
    continue
    expect(page.text).to include(error_message) # required
    check_validation_error_message('Choose a file to upload')
    attach_file('Upload a file', 'spec/fixtures/files/hello_world.txt')
    continue

    # optional upload page to check for adding and removing files
    check_optional_text(page.text)
    attach_file('Optional file upload', 'spec/fixtures/files/goodbye_world.txt')
    continue

    # attach file to multi file
    check_optional_text(page.text)
    continue
    sleep 2
    expect(page.text).to include(error_message) # required
    check_validation_error_message('Choose a file to upload')
    attach_file('answers-multifile-multiupload-1-field-error', 'spec/fixtures/files/hello_world_multi_1.txt')
    continue
    expect(page.text).to include('hello_world_multi_1.txt')
    check_optional_text(page.text)
    form.add_another.click
    attach_file('answers-multifile-multiupload-1-field', 'spec/fixtures/files/hello_world_multi_1.txt')
    continue
    expect(page.text).to include('The selected file cannot have the same name as a file you have already selected')
    form.add_another.click
    attach_file('answers-multifile-multiupload-1-field-error', 'spec/fixtures/files/hello_world_multi_2.txt')
    continue
    form.delete_file.click
    expect(page.text).not_to include('hello_world_multi_1.txt')
    expect(page.text).to include('hello_world_multi_2.txt')
    form.add_another.click
    attach_file('answers-multifile-multiupload-1-field', 'spec/fixtures/files/hello_world_multi_1.txt')
    continue
    expect(page.text).to include('hello_world_multi_1.txt')
    expect(page.text).to include('hello_world_multi_2.txt')
    continue

    # optional multi upload upload page
    check_optional_text(page.text)
    expect(page.text).to include('Optional multi file upload')
    continue

    # autocomplete
    check_optional_text(page.text)
    form.autocomplete_countries_field.set("Wonderland\n")
    continue
    check_error_message(page.text, [form.find('h1').text])
    form.autocomplete_countries_field.set("Na")
    find('li.autocomplete__option', text: 'Narnia').click
    continue

    # hotel address
    check_optional_text(page.text)
    expect(page.text).to include('What is your hotel address?')
    form.address_line_1.set('999 street')
    form.city.set('Wondercity')
    form.postcode.set('SW1H 9AJ')
    continue

    # check your answers
    check_optional_text(page.text)
    expect(page.text).to include('First name Stormtrooper')
    expect(page.text).to include("Last name #{generated_name}")
    expect(page.text).to include('Your email address fb-acceptance-tests+confirmation@digital.justice.gov.uk')
    expect(page.text).to include('Your cat My cat is a fluffy killer £ % ~ ! @ # $ ^ * ( ) - _ = + [ ] | ; , . ?')
    expect(page.text).to include('Optional text (Optional)')
    expect(page.text).to include('Optional textarea (Optional)')
    expect(page.text).to include('Optional number (Optional)')
    expect(page.text).to include('Optional radios (Optional)')
    expect(page.text).to include('Celery')
    expect(page.text).to include('Optional date (Optional)')
    expect(page.text).to include("Your fruit Apples\nPears")
    expect(page.text).to include('12 November 2007')
    expect(page.text).to include('How many cats have chosen you? 5')
    expect(page.text).to include('Is your cat watching you now? Yes')
    expect(page.text).to include('Upload a file hello_world.txt')
    expect(page.text).to include('Optional file upload (Optional) goodbye_world.txt')
    expect(page.text).to include('Narnia')
    expect(page.text).to include("999 street\nWondercity\nSW1H 9AJ\nUnited Kingdom")

    expect(page.text).to include('We will send a confirmation email with a copy of these answers to')

    # Checking changing answer for optional checkboxes
    # Also checking optional checkboxes will remove a users previous answer
    form.change_optional_checkbox.click
    form.find(:css, '#optional-questions_checkboxes_1').uncheck('Celery', visible: false)
    continue
    expect(page.text).to include('Check your answers')
    expect(page.text).not_to include('Celery')

    # Checking removing file for optional file upload
    form.change_optional_file_upload.click
    form.remove_file.click
    continue
    expect(page.text).to include('Check your answers')
    expect(page.text).to include('Optional file upload (Optional)')
    expect(page.text).not_to include('goodbye_world.text')

    # Check changing answer for autocomplete component
    form.change_autocomplete.click
    form.autocomplete_countries_field.set("W")
    find('li.autocomplete__option', text: 'Wakanda').click
    continue
    expect(page.text).to include('Check your answers')
    expect(page.text).not_to include('Narnia')

    form.submit_button.click

    expect(page.text).to include("You've sent us the answers about your cat!")
    expect(page).to have_css('.govuk-button', text: 'Continue to pay')
    reference_number = page.find(:css, 'strong').text
    expect(page.text).to include('Your reference number is:')
    expect(page.text).to include(reference_number)

    # confirmation_email = get_confirmation_email(reference_number)
    # submission_email = get_submission_email(reference_number)
    # submission_csv_email = get_submission_email(reference_number, 'CSV - Submission from')

    # confirmation_message_body = email_body(confirmation_email[0])
    # submission_message_body = email_body(submission_email[0])
    # submission_csv_message_body = email_body(submission_csv_email[0])

    # expect(confirmation_email[0].reply_to).to include('fb-acceptance-tests+reply-to@digital.justice.gov.uk')
    # expect(confirmation_email[0].from).to include('new-runner-acceptance-tests')

    # some_answers = 'Where do you like to holiday?WK'
    # expect(confirmation_message_body).to include(some_answers)
    # expect(submission_message_body).to include(some_answers)
    # expect(submission_csv_message_body).to be_blank

    # pdf_attachments = find_pdf_attachments(id: reference_number, expected_emails: 1)
    # csv_attachments = find_csv_attachments(id: reference_number)

    # assert_pdf_contents(pdf_attachments, reference_number)
    # assert_csv_contents(csv_attachments, reference_number)

    # assert_ms_list_item_contents(reference_number)

    # we read all the attached files into one string, then compare against expected uploads
    # attached_files = pdf_attachments[:multi_uploads].split("\n")
    # expect(attached_files.include?(File.read('spec/fixtures/files/hello_world.txt').strip)).to eq(true)
    # expect(attached_files.include?(File.read('spec/fixtures/files/hello_world_multi_1.txt').strip)).to eq(true)
    # expect(attached_files.include?(File.read('spec/fixtures/files/hello_world_multi_2.txt').strip)).to eq(true)
  end

  def assert_ms_list_item_contents(reference_number)
    sleep (20) # we have to wait for email to arrive before MS list post is processed 

    uri = URI.parse("#{root_graph_url}/sites/#{site_id}/lists/#{list_id}/items")
    connection ||= Faraday.new(uri) do |conn|
    end

    res = connection.get do |req|
      req.headers['Authorization'] = "Bearer #{get_auth_token}"
      req.body = body.to_json
    end

    row_id = JSON.parse(res.body)['value'].last['id']
  
    single_item_uri = URI.parse("#{root_graph_url}/sites/#{site_id}/lists/#{list_id}/items/#{row_id}?expand=fields")
    connection_2 ||= Faraday.new(single_item_uri) do |conn|
    end

    res = connection_2.get do |req|
      req.headers['Authorization'] = "Bearer #{get_auth_token}"
      req.body = body.to_json
    end

    row = JSON.parse(res.body)['fields'].values

    expect(row).to include('Stormtrooper')
    expect(row).to include(generated_name)
    expect(row).to include(reference_number)
    expect(row).to include('fb-acceptance-tests+confirmation@digital.justice.gov.uk')
    expect(row).to include('My cat is a fluffy killer £ % ~ ! @ # $ ^ * ( ) - _ = + [ ] | ; , . ?')
    expect(row).to include('WK')
    expect(row).to include("Apples; Pears")
    expect(row).to include('12 November 2007')
    expect(row).to include('5')
    expect(row).to include('Yes')
    expect(row).to include("hotel-address_address_1; What is your hotel address? (optional); &#123;&quot;address_line_one&quot;=&gt;&quot;999 street&quot;, &quot;address_line_two&quot;=&gt;&quot;&quot;, &quot;city&quot;=&gt;&quot;Wondercity&quot;, &quot;county&quot;=&gt;&quot;&quot;, &quot;postcode&quot;=&gt;&quot;SW1H 9AJ&quot;, &quot;country&quot;=&gt;&quot;United Kingdom&quot;&#125;")
    expect(row.any?(/\/sites\/MoJFormsDevelopment\/Shared%20Documents\/new-runner-acceptance-tests-test/)).to eq(true)
    expect(row.any?(/hello_world_multi_1.txt/)).to eq(true)
    expect(row.any?(/hello_world.txt/)).to eq(true)
  end

  def assert_pdf_contents(attachments, reference_number)
    pdf_path = "/tmp/submission-#{SecureRandom.uuid}.pdf"
    File.open(pdf_path, 'w') do |file|
      file.write(attachments[:pdf_answers])
    end
    result = PDF::Reader.new(pdf_path).pages.map do |page|
      page.text
    end.join(' ')
    p 'Asserting PDF contents'

    pdf_text_includes_id?(result, reference_number)

    expect(result).to include('tests')

    # text
    # Not possible to test this at the moment as we are holding sections feature
    # expect(result).to include('Your name')
    expect(result).to match(/First name[\n\r\s]+Stormtrooper/)
    expect(result).to match(/Last name[\n\r\s]+#{generated_name}/)

    # email
    expect(result).to include('Your email address')
    expect(result).to include('fb-acceptance-tests+confirmation@digital.justice.gov.uk')

    # textarea
    expect(result).to include('Your cat')
    expect(result).to include('My cat is a fluffy killer £ % ~ ! @ # $ ^ * ( ) - _ = + [ ] | ; , . ?')

    # optional fields
    # these are actually the question text for each component, not optional hint text
    expect(result).to include('Optional text (Optional)')
    expect(result).to include('Optional textarea')
    expect(result).to include('Optional number')
    expect(result).to include('Optional radios')
    expect(result).to include('Optional checkboxes')
    expect(result).to include('Optional date (Optional)')

    # checkbox
    expect(result).to include('Your fruit')
    expect(result).to include('Apples')
    expect(result).to include('Pears')

    # date
    expect(result).to include('When did your cat')
    expect(result).to include('choose you?')
    expect(result).to include('12 November 2007')

    # number
    expect(result).to include('How many cats have')
    expect(result).to include('chosen you?')
    expect(result).to include('5')

    # file upload (legacy single file)
    expect(result).to include('Upload a file')
    expect(result).to include('hello_world.txt')

    # optional file upload (legacy single file)
    expect(result).to include('Optional file upload')
    expect(result).not_to include('goodbye_world.text')

    # multifile upload
    expect(result).to include('Multi file upload')
    expect(result).to include('hello_world_multi_1.txt')
    expect(result).to include('hello_world_multi_2.txt')
    
    # optional multi file upload
    expect(result).to include('Optional multi file')

    # autocomplete
    expect(result).to include('Where do you like to')
    expect(result).to include('holiday?')
    expect(result).to include('WK')

    # address component
    expect(result).to include('999 street, Wondercity, SW1H 9AJ, United Kingdom')

    # optional text
    check_optional_text(result)
  end

  def assert_csv_contents(attachments, reference_number)
    content = attachments[:csvs].first || ""
    csv_path = "/tmp/submission-#{SecureRandom.uuid}.csv"
    File.open(csv_path, 'w') do |file|
      file.write(content)
    end
    rows = CSV.read(csv_path)

    p 'Asserting CSV contents'

    expect(rows[0]).to match_array(%w[
      reference_number
      submission_at name_text_1
      name_text_2
      your-email-address_email_1
      your-cat_textarea_1
      optional-questions_text_1
      optional-questions_textarea_1
      optional-questions_number_1
      optional-questions_radios_1
      optional-questions_checkboxes_1
      optional-questions_date_1
      your-fruit_checkboxes_1
      when_date_1
      how-many_number_1
      watch_radios_1
      file-upload_upload_1
      optional-file-upload_upload_1
      multifile_multiupload_1
      multi-optional_multiupload_1
      countries_autocomplete_1
      hotel-address_address_1/address_line_one
      hotel-address_address_1/address_line_two
      hotel-address_address_1/city
      hotel-address_address_1/county
      hotel-address_address_1/postcode
      hotel-address_address_1/country
    ])

    expect(rows[1][0]).to match(reference_number) # guid
    expect(rows[1][1]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z/) # iso timestamp
    expect(rows[1][2..]).to match_array([
      'Stormtrooper',
      generated_name,
      'fb-acceptance-tests+confirmation@digital.justice.gov.uk',
      'My cat is a fluffy killer £ % ~ ! @ # $ ^ * ( ) - _ = + [ ] | ; , . ?',
      '',
      '',
      '',
      '',
      '',
      '',
      'Apples; Pears',
      '12 November 2007',
      '5',
      'Yes',
      'hello_world.txt',
      'hello_world_multi_2.txt; hello_world_multi_1.txt',
      '',
      '',
      'WK',
      '999 street',
      '',
      'Wondercity',
      '',
      'SW1H 9AJ',
      'United Kingdom'
    ])
  end

  def get_auth_token
    response = auth_connection.post do |req|
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.body = URI.encode_www_form(form_data)
    end

    response_body = JSON.parse(response.body)

    response_body['access_token']
  end

  def auth_connection
    @auth_connection ||= Faraday.new(URI.parse(auth_url)) do |conn|
      conn.response :raise_error
      conn.request :multipart
      conn.request :url_encoded
      conn.adapter :net_http
    end
  end

  def form_data
    {
      client_id: admin_app,
      client_secret: admin_secret,
      grant_type: 'client_credentials',
      resource: 'https://graph.microsoft.com/'
    }
  end

  def admin_app
    ENV['MS_ADMIN_APP_ID']
  end

  def admin_secret
    ENV['MS_ADMIN_APP_SECRET']
  end

  def auth_url
    ENV['MS_OAUTH_URL']
  end

  def root_graph_url
    'https://graph.microsoft.com/v1.0/'
  end

  def site_id
    ENV['MS_SITE_ID']
  end

  def list_id
    ENV['MS_LIST_ID']
  end
end
