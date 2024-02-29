require 'spec_helper'

describe 'Form with locale set to welsh' do
  before :each do
    OutputRecorder.cleanup_recorded_requests if ENV['CI_MODE'].blank?
  end

  let(:form) { WelshLocaleApp.new }

  before { form.load }

  it 'has welsh localisation' do
    expect(form).to have_accept_analytics_button
    expect(form).to have_reject_analytics_button
    expect(form).to have_view_cookies_link

    form.reject_analytics_button.click
    expect(form).to have_hide_cookie_message_button
    form.hide_cookie_message_button.click
    expect(form).not_to have_hide_cookie_message_button

    footer_links = form.footer_links.map(&:text)
    expect(footer_links).to eq(%w[Cwcis Preifatrwydd Hygyrchedd])

    form.footer_links.first.click
    expect(form.text).to include('Cwcis hanfodol')
    expect(form.text).to include('Cwcis dadansoddol')

    # go back to the home
    form.load
    expect(form).to have_start_now_button
    form.start_now_button.click

    # full name page
    expect(form).to have_back_link
    expect(form).to have_continue_button
    expect(form).to have_save_form_button

    # provoke a blank error
    form.continue_button.click
    expect(form.text).to include('Mae yna broblem')
    expect(form.text).to include('Rhowch ateb i "Ehowch eich enw llawn"')

    # fix error and continue
    form.fullname_question.set('John Doe')
    form.continue_button.click

    # address page
    expect(form).to have_address_line_one
    expect(form).to have_address_line_two
    expect(form).to have_city
    expect(form).to have_county
    expect(form).to have_postcode
    expect(form).to have_country

    # provoke blank and postcode errors
    form.postcode.set('12345')
    form.continue_button.click
    expect(form.text).to include('Mae yna broblem')
    expect(form.text).to include('Nodwch llinell cyfeiriad 1 ar gyfer "Ehowch eich cyfeiriad cartref"')
    expect(form.text).to include('Nodwch tref neu ddinas ar gyfer "Ehowch eich cyfeiriad cartref"')
    expect(form.text).to include('Nodwch god post y DU dilys ar gyfer "Ehowch eich cyfeiriad cartref"')

    # fix errors and continue
    form.address_line_one.set('Street 123')
    form.city.set('Wondercity')
    form.country.set('Wonderland')
    form.continue_button.click

    # check your answers page
    expect(form).to have_back_link
    expect(form.text).to include('Gwiriwch eich atebion')
    expect(form.text).to include('Newid')

    # save for later smoke test
    form.save_form_button.click
    expect(form.text).to include('Cadw at yn hwyrach ymlaen')
    expect(form.text).to include('Cyfeiriad e-bost')
    expect(form.text).to include('Dewiswch gwestiwn diogelwch')
    expect(form.text).to include('Eich ateb i’ch cwestiwn diogelwch')

    # return to check your answers and submit
    expect(form).to have_cancel_and_resume_button
    form.cancel_and_resume_button.click
    expect(form).to have_submit_button
    form.submit_button.click
    expect(form.text).to include('Cais wedi\'i gwblhau')
  end
end
