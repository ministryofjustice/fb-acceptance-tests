require 'capybara/rspec'
require 'spec_helper'
require 'httparty'

describe 'Interacting with cookie banner' do
  context 'accepting analytics' do
    let(:form) { ComponentsNumberApp.new }
    let(:cookie_banner_text) { 'Cookies on Number Acceptance Test Service' }
    let(:cookie_accepted_text) { "You've accepted analytics cookies" }

    it 'shows the cookie banner and accepted message' do
      form.load
      expect(form.text).to include(cookie_banner_text)

      form.accept_analytics.click
      expect(form.text).to include(cookie_accepted_text)

      form.hide_cookie_message.click
      expect(form.text).not_to include(cookie_accepted_text)
    end
  end

  context 'rejecting analytics' do
    let(:form) { ComponentsDateApp.new }
    let(:cookie_banner_text) { 'Cookies on Date Acceptance Test Service' }
    let(:cookie_rejected_text) { "You've rejected analytics cookies" }

    it 'shows the cookie banner and rejected message' do
      form.load
      expect(form.text).to include(cookie_banner_text)

      form.reject_analytics.click
      expect(form.text).to include(cookie_rejected_text)

      form.hide_cookie_message.click
      expect(form.text).not_to include(cookie_rejected_text)
    end
  end
end
