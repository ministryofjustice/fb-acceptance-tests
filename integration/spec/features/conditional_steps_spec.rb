require 'capybara/rspec'
require 'spec_helper'

describe 'Conditional steps' do
  let(:form) { FeaturesConditionalSteps.new }
  before do
    form.load
    form.start_button.click
  end

  it 'all questions are answered' do
    given_I_answer_all_questions

    ########################################
    #                                      #
    #   SUMMARY                            #
    #                                      #
    ########################################

    expect(form.all_headings).to include('Summary')

    expect(form.summary_answers.size).to be(5)

    expect(form.first_answer).to include('Radios One')
    expect(form.second_answer).to include("Checkboxes\nA\nB\nC")
    expect(form.third_answer).to include(
      'Email form-builder-developers@digital.justice.gov.uk'
    )
    expect(form.fourth_answer).to include('Number 1')
    expect(form.fifth_answer).to include('Text a Change')

    form.send_application_button.click

    expect(form.confirmation_header).to have_text('Confirmation')
  end

  it 'when answers go to another conditional branch' do
    form.second_option.choose
    form.continue_button.click

    ########################################
    #                                      #
    #   SUMMARY                            #
    #                                      #
    ########################################

    expect(form.all_headings).to include('Summary')
    expect(form.summary_answers.size).to be(1)
    expect(form.first_answer).to include('Radios Two')

    form.send_application_button.click
    expect(form.confirmation_header).to have_text('Confirmation')
  end

  it 'when answer all pages then change answers on summary page' do
    given_I_answer_all_questions

    ########################################
    #                                      #
    #   CHANGE                             #
    #                                      #
    ########################################

    expect(form.all_headings).to include('Summary')
    expect(form.summary_answers.size).to be(5)
    expect(form.second_answer).to include("Checkboxes\nA\nB\nC")

    # change second answer
    form.change_links[1].click

    form.c_field.uncheck
    form.continue_button.click

    ## Navigating again to the conditional pages
    expect(form.section_heading.text).to eq('Email section heading')
    form.continue_button.click

    ## Navigating again to the conditional pages
    expect(form.section_heading.text).to eq('Number section heading')
    form.continue_button.click

    ########################################
    #                                      #
    #   SUMMARY                            #
    #                                      #
    ########################################

    expect(form.section_heading.text).to eq('Summary section heading')
    expect(form.all_headings).to include('Summary')

    ########################################
    #                                      #
    #   CHANGE                             #
    #                                      #
    ########################################

    # change second answer again
    form.change_links[1].click

    form.b_field.uncheck
    form.c_field.uncheck
    form.continue_button.click

    ## Navigating again to the conditional pages
    expect(form.section_heading.text).to eq('Email section heading')
    form.continue_button.click

    ########################################
    #                                      #
    #   SUMMARY                            #
    #                                      #
    ########################################

    expect(form.section_heading.text).to eq('Summary section heading')
    expect(form.all_headings).to include('Summary')
    expect(form.second_answer).to include("Checkboxes A Change\nYour answer")

    ########################################
    #                                      #
    #   CHANGE                             #
    #                                      #
    ########################################

    # change second answer again
    form.change_links[1].click

    form.a_field.uncheck
    form.b_field.uncheck
    form.c_field.uncheck
    form.continue_button.click

    ########################################
    #                                      #
    #   SUMMARY                            #
    #                                      #
    ########################################

    expect(form.section_heading.text).to eq('Summary section heading')
    expect(form.all_headings).to include('Summary')
    expect(form.second_answer).to include(
      "Checkboxes Not answered Change\nYour answer"
    )

    form.send_application_button.click
    expect(form.confirmation_header).to have_text('Confirmation')
  end

  it 'when going back to the conditional pages that I answered' do
    given_I_answer_all_questions

    ########################################
    #                                      #
    #   BACK                               #
    #                                      #
    ########################################
    back

    expect(form.section_heading.text).to eq('Text section heading')

    ########################################
    #                                      #
    #   BACK                               #
    #                                      #
    ########################################
    back

    expect(form.section_heading.text).to eq('Number section heading')

    ########################################
    #                                      #
    #   BACK                               #
    #                                      #
    ########################################
    back

    expect(form.section_heading.text).to eq('Email section heading')

    ########################################
    #                                      #
    #   BACK                               #
    #                                      #
    ########################################
    back
    expect(form.section_heading.text).to eq('Checkboxes section heading')

    form.a_field.check
    form.b_field.check
    form.c_field.uncheck
    form.continue_button.click

    expect(form.section_heading.text).to eq('Email section heading')
    form.continue_button.click

    expect(form.section_heading.text).to eq('Number section heading')
    form.continue_button.click

    ########################################
    #                                      #
    #   SUMMARY                            #
    #                                      #
    ########################################
    expect(form.section_heading.text).to eq('Summary section heading')

    ########################################
    #                                      #
    #   BACK                               #
    #                                      #
    ########################################
    back

    expect(form.section_heading.text).to eq('Number section heading')

    ########################################
    #                                      #
    #   BACK                               #
    #                                      #
    ########################################
    back
    expect(form.section_heading.text).to eq('Email section heading')

    ########################################
    #                                      #
    #   BACK                               #
    #                                      #
    ########################################
    back

    expect(form.section_heading.text).to eq('Checkboxes section heading')

    form.a_field.check
    form.b_field.uncheck
    form.c_field.uncheck
    form.continue_button.click

    expect(form.section_heading.text).to eq('Email section heading')
    form.continue_button.click

    ########################################
    #                                      #
    #   SUMMARY                            #
    #                                      #
    ########################################
    expect(form.section_heading.text).to eq('Summary section heading')

    ########################################
    #                                      #
    #   BACK                               #
    #                                      #
    ########################################
    back

    expect(form.section_heading.text).to eq('Email section heading')

    ########################################
    #                                      #
    #   BACK                               #
    #                                      #
    ########################################
    back

    expect(form.section_heading.text).to eq('Checkboxes section heading')

    form.a_field.uncheck
    form.b_field.uncheck
    form.c_field.uncheck
    form.continue_button.click

    ########################################
    #                                      #
    #   SUMMARY                            #
    #                                      #
    ########################################
    expect(form.section_heading.text).to eq('Summary section heading')

    form.send_application_button.click
    expect(form.confirmation_header).to have_text('Confirmation')
  end

  it 'when I answer without entering conditional pages & I change my answers' do
    form.second_option.choose
    form.continue_button.click

    ########################################
    #                                      #
    #   SUMMARY                            #
    #                                      #
    ########################################
    expect(form.section_heading.text).to eq('Summary section heading')

    ########################################
    #                                      #
    #   CHANGE                             #
    #                                      #
    ########################################

    # change first answer
    form.change_links[0].click

    form.first_option.choose
    form.continue_button.click

    expect(form.section_heading.text).to eq('Checkboxes section heading')

    form.a_field.check
    form.b_field.check
    form.c_field.check
    form.continue_button.click

    expect(form.section_heading.text).to eq('Email section heading')
    form.email_field.set('form-builder-developers@digital.justice.gov.uk')
    form.continue_button.click

    expect(form.section_heading.text).to eq('Number section heading')
    form.number_field.set('1')
    form.continue_button.click

    expect(form.section_heading.text).to eq('Text section heading')
    form.text_field.set('Foo')
    form.continue_button.click

    ########################################
    #                                      #
    #   SUMMARY                            #
    #                                      #
    ########################################
    expect(form.section_heading.text).to eq('Summary section heading')

    # change first answer
    form.change_links[0].click

    form.second_option.choose
    form.continue_button.click

    expect(form.section_heading.text).to eq('Email section heading')
    form.continue_button.click
    expect(form.section_heading.text).to eq('Number section heading')
    form.continue_button.click
    expect(form.section_heading.text).to eq('Text section heading')
    form.continue_button.click

    ########################################
    #                                      #
    #   SUMMARY                            #
    #                                      #
    ########################################
    expect(form.section_heading.text).to eq('Summary section heading')

    expect(form.first_answer).to include('Radios Two')

    form.send_application_button.click
    expect(form.confirmation_header).to have_text('Confirmation')
  end

  it 'when I am going back and enter conditional pages' do
    form.second_option.choose
    form.continue_button.click

    ########################################
    #                                      #
    #   SUMMARY                            #
    #                                      #
    ########################################
    expect(form.section_heading.text).to eq('Summary section heading')

    ########################################
    #                                      #
    #   BACK                               #
    #                                      #
    ########################################
    back

    expect(form.section_heading.text).to eq('Radios section heading')
    form.first_option.choose
    form.continue_button.click

    expect(form.section_heading.text).to eq('Checkboxes section heading')
    form.a_field.check
    form.b_field.check
    form.c_field.check
    form.continue_button.click

    expect(form.section_heading.text).to eq('Email section heading')
    form.email_field.set('form-builder-developers@digital.justice.gov.uk')
    form.continue_button.click

    expect(form.section_heading.text).to eq('Number section heading')
    form.number_field.set('1')
    form.continue_button.click

    expect(form.section_heading.text).to eq('Text section heading')
    form.text_field.set('Foo')
    form.continue_button.click

    ########################################
    #                                      #
    #   SUMMARY                            #
    #                                      #
    ########################################
    expect(form.section_heading.text).to eq('Summary section heading')

    ########################################
    #                                      #
    #   BACK                               #
    #                                      #
    ########################################
    back
    expect(form.section_heading.text).to eq('Text section heading')
    back
    expect(form.section_heading.text).to eq('Number section heading')
    back
    expect(form.section_heading.text).to eq('Email section heading')
    back
    expect(form.section_heading.text).to eq('Checkboxes section heading')

    form.a_field.check
    form.b_field.check
    form.c_field.uncheck
    form.continue_button.click

    expect(form.section_heading.text).to eq('Email section heading')
    form.continue_button.click
    expect(form.section_heading.text).to eq('Number section heading')
    form.continue_button.click

    ########################################
    #                                      #
    #   SUMMARY                            #
    #                                      #
    ########################################
    expect(form.section_heading.text).to eq('Summary section heading')

    ########################################
    #                                      #
    #   BACK                               #
    #                                      #
    ########################################
    back
    expect(form.section_heading.text).to eq('Number section heading')
    back
    expect(form.section_heading.text).to eq('Email section heading')
    back
    expect(form.section_heading.text).to eq('Checkboxes section heading')

    form.a_field.check
    form.b_field.uncheck
    form.c_field.uncheck
    form.continue_button.click

    expect(form.section_heading.text).to eq('Email section heading')
    form.continue_button.click

    ########################################
    #                                      #
    #   SUMMARY                            #
    #                                      #
    ########################################
    expect(form.section_heading.text).to eq('Summary section heading')

    ########################################
    #                                      #
    #   BACK                               #
    #                                      #
    ########################################
    back
    expect(form.section_heading.text).to eq('Email section heading')
    back

    expect(form.section_heading.text).to eq('Checkboxes section heading')
    form.a_field.uncheck
    form.b_field.uncheck
    form.c_field.uncheck
    form.continue_button.click

    expect(form.section_heading.text).to eq('Summary section heading')
    form.send_application_button.click
    expect(form.confirmation_header).to have_text('Confirmation')
  end

  def back
    find('.govuk-back-link').click
  end

  def continue
    click_on 'Continue'
  end

  def given_I_answer_all_questions
    form.first_option.choose
    form.continue_button.click

    form.a_field.check
    form.b_field.check
    form.c_field.check
    form.continue_button.click

    form.email_field.set('form-builder-developers@digital.justice.gov.uk')
    form.continue_button.click

    form.number_field.set('1')
    form.continue_button.click

    form.text_field.set('a')
    form.continue_button.click
  end
end
