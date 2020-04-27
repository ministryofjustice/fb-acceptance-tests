require 'capybara/rspec'
require 'spec_helper'

class ConditionalsWithUploadPage < SitePrism::Page
  set_url 'http://components-upload-with-conditional-app:3000'

  element :start_button, :button, 'Start'
  element :back_link, :link, 'Back'
  element :tuesday_today_yes,
          :radio_button,
          'Yes',
          name: 'tuesday_today',
          visible: false,
          option: 'yes'
  element :tuesday_today_no,
          :radio_button,
          'No',
          name: 'tuesday_today',
          visible: false,
          option: 'no'
  element :confirm_upload_field, :radio_button, 'Yes, add this upload', visible: false
  element :continue_button, :button, 'Continue'
  elements :summaries, 'dl .govuk-summary-list__value'
  elements :headings, '.govuk-heading-xl'
  elements :change_links, '.govuk-summary-list__actions a.govuk-link'

  def change_tuesday_answer_link
    change_links.first
  end

  def in_summaries_page?
    headings.map(&:text).include?('Check your answers')
  end

  def tuesday_today_summary_text
    summaries.first.text
  end

  def uploaded_file_summary_text
    summaries.last.text
  end
end

describe 'Conditionals with Upload components' do
  let(:form) { ConditionalsWithUploadPage.new }

  before do
    form.load
    form.start_button.click
  end

  context 'when I answer "Yes" in all pages' do
    it 'navigation should render successfully' do
      form.tuesday_today_yes.choose
      form.continue_button.click
      attach_file("auto_name__2[1]", 'spec/fixtures/files/hello_world.txt')

      form.continue_button.click
      form.confirm_upload_field.choose

      # check upload
      form.continue_button.click

      # upload summaries
      form.continue_button.click

      expect(form).to be_in_summaries_page
      expect(form.uploaded_file_summary_text).to include('hello_world.txt')
    end
  end

  context 'when I answer "No" in all pages' do
    it 'navigation should render successfully' do
      form.tuesday_today_no.choose
      form.continue_button.click

      expect(form).to be_in_summaries_page
      expect(form.tuesday_today_summary_text).to eq('No')
    end
  end

  context 'when I change my mind in the answers' do
    it 'I should be able to go back and change branches on conditionals' do
      form.tuesday_today_no.choose
      form.continue_button.click

      expect(form).to be_in_summaries_page

      form.change_tuesday_answer_link.click

      form.tuesday_today_yes.choose
      form.continue_button.click
      attach_file("auto_name__2[1]", 'spec/fixtures/files/hello_world.txt')

      form.continue_button.click
      form.confirm_upload_field.choose

      # check upload
      form.continue_button.click

      # upload summaries
      form.continue_button.click

      expect(form).to be_in_summaries_page
      expect(form.uploaded_file_summary_text).to include('hello_world.txt')

      form.change_tuesday_answer_link.click

      form.tuesday_today_no.choose
      form.continue_button.click

      expect(form).to be_in_summaries_page
      expect(form.tuesday_today_summary_text).to eq('No')
      expect(form.summaries.size).to be(1)
    end
  end
end
