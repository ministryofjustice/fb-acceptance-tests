require 'pdf-reader'

describe 'New Runner' do
  before :each do
    OutputRecorder.cleanup_recorded_requests if ENV['CI_MODE'].blank?
  end
  let(:form) { NewRunnerApp.new }
  let(:username) { ENV['NEW_RUNNER_ACCEPTANCE_TEST_USER'] }
  let(:password) { ENV['NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD'] }
  let(:generated_name) { "FN-#{SecureRandom.uuid}" }
  let(:error_message) { 'There is a problem' }

  before { form.load }

  it 'sends an email with the submission in a PDF' do
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
    form.email_field.set('fb-acceptance-tests@digital.justice.gov.uk')
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
    check_error_message(page.text, [form.find('h1').text])
    form.yes_field.choose
    continue

    # attach file
    check_optional_text(page.text)
    continue
    check_error_message(page.text, [form.find('h1').text])
    attach_file('Upload a file', 'spec/fixtures/files/hello_world.txt')
    continue

    # optional upload page to check for adding and removing files
    check_optional_text(page.text)
    attach_file('Optional file upload', 'spec/fixtures/files/goodbye_world.txt')
    continue

    # check your answers
    check_optional_text(page.text)
    expect(page.text).to include('First name Stormtrooper')
    expect(page.text).to include("Last name #{generated_name}")
    expect(page.text).to include('Your email address fb-acceptance-tests@digital.justice.gov.uk')
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

    form.submit_button.click

    expect(form.text).to include("You've sent us the answers about your cat!")

    attachments = find_attachments(id: generated_name)

    assert_pdf_contents(attachments)

    expect(attachments[:file_upload]).to eq(File.read('spec/fixtures/files/hello_world.txt'))
  end


  def assert_pdf_contents(attachments)
    pdf_path = "/tmp/submission-#{SecureRandom.uuid}.pdf"
    File.open(pdf_path, 'w') do |file|
      file.write(attachments[:pdf_answers])
    end
    result = PDF::Reader.new(pdf_path).pages.map do |page|
      page.text
    end.join(' ')
    p 'Asserting PDF contents'

    expect(result).to include(
      'Submission subheading for new-runner-acceptance-tests'
    )
    expect(result).to include(
      'Submission for new-runner-acceptance-'
    )
    expect(result).to include('tests')

    # text
    # Not possible to test this at the moment as we are holding sections feature
    # expect(result).to include('Your name')
    expect(result).to match(/First name[\n\r\s]+Stormtrooper/)
    expect(result).to match(/Last name[\n\r\s]+#{generated_name}/)

    # email
    expect(result).to include('Your email address')
    expect(result).to include('fb-acceptance-tests@digital.justice.gov.uk')

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

    # file upload
    expect(result).to include('Upload a file')
    expect(result).to include('hello_world.txt')

    # optional file upload
    expect(result).to include('Optional file upload')
    expect(result).not_to include('goodbye_world.text')

    # optional text
    check_optional_text(result)
  end
end
