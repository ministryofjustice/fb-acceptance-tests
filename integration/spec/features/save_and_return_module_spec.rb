require 'capybara/rspec'
require 'spec_helper'

describe 'Using Save and Return', skip: true do
  let(:form) { FeaturesSaveAndReturnApp.new }

  before { form.load }

  it 'puts a link onto the start page' do
    expect(form).to have_continue_work_on_a_saved_form_button
    expect(
      form.continue_work_on_a_saved_form_button.text
    ).to eq('Continue work on a saved form')
  end

  it 'puts a save and return button into the form' do
    form.start_button.click
    expect(form).to have_save_and_come_back_later_button
    expect(
      form.save_and_come_back_later_button.text
    ).to eq('Save and come back later')
  end

  it 'puts a save and return message into the page' do
    form.start_button.click
    expect(form).to have_content(
      /Your session will time out after \d+ minutes of inactivity/
    )
    expect(form).to have_content(
      'Save your details if you want to come back later'
    )
  end

  it 'sets up save and return' do
    form.start_button.click
    form.save_and_come_back_later_button.click

    expect(form).to have_content('Saving your progress')
    form.continue_button.click

    expect(form).to have_content('Save your progress')
    expect(form).to have_email_field

    form.email_field.set('form-builder-developers@digital.justice.gov.uk')
    form.continue_button.click

    expect(form).to have_content('Check your email')
    expect(form).to have_email_message(
      'We have sent an email to form-builder-developers@digital.justice.gov.uk.'
    )
  end

  it 'puts a continue link onto the start page' do
    form.continue_work_on_a_saved_form_button.click

    # Save and Return start
    expect(form).to have_sign_in_link
    expect(form).to have_email_field
  end

  it 'saves and retrieves form submission' do
    form.start_button.click
    form.usn_field.set('9876543')
    form.continue_button.click

    form.save_and_come_back_later_button.click
    form.continue_button.click
    form.email_field.set('form-builder-developers@digital.justice.gov.uk')
    form.continue_button.click

    ## Retrieves the link sent to submitter so we can recover the data
    ## and test properly
    visit("#{ENV.fetch('SAVE_AND_RETURN_SIMULATOR_APP')}/email")

    ## Get the token from the mocked submitter so we can visit and restore
    ## the saved form
    #
    token = page.text.match(/token\/([\w|-]*)/)[1]

    ## User clicking the email
    #
    visit("#{ENV.fetch('FEATURES_SAVE_AND_RETURN_APP')}/return/setup/email/token/#{token}")

    form.continue_with_this_form_button.click
    form.back_link.click
    expect(form.usn_field).to be_visible
    expect(form.usn_field.value).to eq('9876543')
  end

  it 'rejects no email address' do
    form.continue_work_on_a_saved_form_button.click

    # Save and Return start
    expect(form).to have_sign_in_link
    expect(form).to have_email_field

    # email
    form.email_field.set('') # ensure empty
    continue

    expect(form).to have_sign_in_link
    expect(form.email_error_summary.text).to eq(
      'Enter an email address for Email address'
    )

    expect(form.email_error_message.text).to include(
      'Enter an email address for Email address'
    )
  end

  it 'shows the correct error message when the email does not exist in the datastore' do
    form.continue_work_on_a_saved_form_button.click

    form.email_field.set('idontexistinthedatabase@gmail.com')
    continue

    expect(form).to_not have_content(
      "Sorry, we’re currently experiencing technical difficulties"
    )
    expect(form).to have_content('The email was not found')
  end

  def continue
    form.continue_button.click
  end
end
