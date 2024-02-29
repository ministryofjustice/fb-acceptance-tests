require 'spec_helper'

describe 'Form with locale set to welsh' do
  before :each do
    OutputRecorder.cleanup_recorded_requests if ENV['CI_MODE'].blank?
  end

  let(:form) { WelshLocaleApp.new }

  before { form.load }

  it 'has welsh localisation' do
    form.start_now_button.click

    expect(form).to have_accept_analytics_button
    expect(form).to have_reject_analytics_button
    expect(form).to have_view_cookies_link

    form.reject_analytics_button.click
    expect(form).to have_hide_cookie_message_button
    form.hide_cookie_message_button.click
    expect(form).not_to have_hide_cookie_message_button

    footer_links = form.footer_links.map(&:text)
    expect(footer_links).to eq(%w[Cwcis Preifatrwydd Hygyrchedd])

    expect(form).to have_cy_start_now_button
    form.cy_start_now_button.click
  end
end
