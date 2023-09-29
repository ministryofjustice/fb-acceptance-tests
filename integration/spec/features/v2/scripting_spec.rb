describe 'New Runner' do
  let(:form) { NewRunnerApp.new }
  let(:error_message) { 'There is a problem' }
  let(:script) { '<script>alert("who let the dogs out")</script>' }

  it 'does not run JavaScript when scripts are submitted' do
    form.load
    form.start_now_button.click

    form.first_name_field.set(script)
    form.last_name_field.set(script)
    continue
    expect_to_see_403
    go_to_page('/name')

    form.first_name_field.set('name')
    form.last_name_field.set('othername')
    continue

    form.email_field.set(script)
    continue
    expect_to_see_403
    go_to_page('/your-email-address')

    form.email_field.set('name@example.com')
    continue

    # textarea
    fill_in 'Your cat',
      with: script
    continue
    expect_to_see_403
    go_to_page('/your-cat')

    fill_in 'Your cat',
      with: 'one two three four five'
    # optional fields
    continue

    # totally optional page
    continue

    # checkbox
    form.apples_field.check
    continue

    # date
    form.day_field.set(script)
    form.month_field.set(script)
    form.year_field.set(script)
    continue
    expect_to_see_403
    go_to_page('/when')
    form.day_field.set('12')
    form.month_field.set('11')
    form.year_field.set('2007')
    continue

    # number
    form.number_cats_field.set(5)
    continue

    # radio
    form.yes_field.choose
    continue

    # attach file
    attach_file('Upload a file', 'spec/fixtures/files/<img src=a onerror=alert(document.domain)>.txt')
    continue
    expect_to_see_403
    go_to_page('/file-upload')
    attach_file('Upload a file', 'spec/fixtures/files/1.jpg')
    continue

    # optional upload page to check for adding and removing files
    continue

    # multifile upload, continue twice
    attach_file('answers-multifile-multiupload-1-field', 'spec/fixtures/files/<img src=a onerror=alert(document.domain)>.txt')
    continue
    expect_to_see_403
    go_to_page('/multifile')
    attach_file('answers-multifile-multiupload-1-field', 'spec/fixtures/files/hello_world_multi_1.txt')
    continue
    continue

    # optional multi file
    continue

    # autocomplete
    form.autocomplete_countries_field.set("Na")
    find('li.autocomplete__option', text: 'Narnia').click
    continue

    # check your answers
    form.change_first_name.click
    expect(alert_present?).to be_falsey
    continue

    form.change_last_name.click
    expect(alert_present?).to be_falsey
    continue

    form.change_email.click
    expect(alert_present?).to be_falsey
    continue

    form.change_cat.click
    expect(alert_present?).to be_falsey
    continue

    form.change_upload.click
    expect(alert_present?).to be_falsey
  end

  def continue
    form.continue_button.click
  end

  def go_to_page(url)
    form.set_url(url)
    form.load
  end

  def expect_to_see_403
    expect(page.text).to include('403')
  end

  def check_date_error_message(text, fields)
    expect(page.text).to include(error_message)
    fields.each { |field| expect(text).to include("Enter a valid date for \"#{field}\"")}
  end

  def alert_present?
    begin
      page.driver.browser.switch_to.alert.accept
      true
    rescue
      Selenium::WebDriver::Error::NoAlertPresentError
      false
    end
  end
end
