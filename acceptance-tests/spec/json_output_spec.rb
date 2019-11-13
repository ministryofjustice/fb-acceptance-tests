require 'capybara/rspec'
require 'spec_helper'
require 'httparty'
require 'jwe'

describe 'JSON Output' do
  it 'sends the JSON payload to the specified endpoint' do
    visit 'http://runner-app:3000'
    click_on 'Start'

    # text
    fill_in 'First name', with: 'Bob'
    fill_in 'Last name', with: 'Smith'
    continue

    # radio
    choose 'has-email', option: 'yes', visible: false
    continue

    # email
    fill_in 'Your email address', with: 'bob.smith@digital.justice.gov.uk'
    continue

    # text
    fill_in 'complaint_details', with: 'Foo bar baz'
    continue

    # checkbox
    check 'Apples', visible: false
    continue

    # date
    fill_in 'COMPOSITE.date-day', with: '12'
    fill_in 'COMPOSITE.date-month', with: '11'
    fill_in 'COMPOSITE.date-year', with: '2007'
    continue

    # number
    fill_in 'number_cats', with: 28
    continue

    # select
    select "I can't say (They can read)", from: 'cat_spy'
    continue

    # autocomplete
    fill_in 'page_autocomplete--autocomplete_autocomplete', with: "California Spangled\n" # the new line "presses enter" on the selected option
    continue

    click_on 'Send complaint'

    encrypted_result = wait_for_json_submission

    result = JSON.parse(JWE.decrypt(encrypted_result, ENV.fetch('SERVICE_OUTPUT_JSON_KEY')), symbolize_names: true)

    expect(result).to include(serviceSlug: 'slug')
    expect(result).to include(submissionAnswers: {
      first_name: 'Bob',
      last_name: 'Smith',
      'has-email': 'yes',
      email_address: 'bob.smith@digital.justice.gov.uk',
      complaint_details: 'Foo bar baz',
      date: '2007-11-12',
      number_cats: 28,
      cat_spy: 'machine answer 3',
      cat_breed: 'California Spangled',
      'checkbox-apples': 'yes'
    })

    expect(result).to include(attachments: [])
    expect(result).to have_key(:submissionId)
  end

  def continue
    click_on 'Continue'
  end

  def wait_for_json_submission(tries = 0, max_tries = 10)
    until HTTParty.get(ENV.fetch('JSON_ENDPOINT')).success?
      p 'waiting for JSON result'
      fail 'JSON assertion timeout' if tries >= max_tries

      tries += 1
      sleep 2
    end

    HTTParty.get(ENV.fetch('JSON_ENDPOINT')).body
  end
end
