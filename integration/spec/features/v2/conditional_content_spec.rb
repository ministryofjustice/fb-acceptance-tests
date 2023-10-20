describe 'Conditional Content' do
  let(:form) { ConditionalContentV2App.new }
  let(:always_content) { 'This is always shown' }
  let(:never_content) { 'This is never shown' }
  let(:logic_combination_content) { 'If radio is a && checkbox is 1 OR radio is b && checkbox is 2' }
  let(:negative_logic_combination) { 'If radio is not a OR checkbox is not Option 1 OR checkbox is not Option 2' }
  let(:checkbox_contains_substring) { 'If checkbox contains Option, it should not show if Option 1 or Option 2' }
  let(:optional_question_unanswered) { 'If checkbox is not answered' }
  let(:and_rule) { 'If radio a && checkbox Option 1' }
  let(:or_rule) { 'If radio b II checkbox Option 2' }
  let(:legacy_content) { 'This is legacy conditional content that should be picked up by default' }

  before { form.load }
  # comment above line and uncomment below and export user and password ENV vars for local testing
  # before { visit "https://#{username}:#{password}@new-runner-acceptance-tests.dev.test.form.service.justice.gov.uk" }


  it 'shows appropriate conditional content depending on users answers' do
    form.start_now_button.click
    form.radio_a.choose
    continue
    form.checkbox_1.check
    continue
    expect(page.text).to include(always_content)
    expect(page.text).not_to include(never_content)
    expect(page.text).to include(and_rule)
    expect(page.text).to include(logic_combination_content)

    # Check with negative logic
    form.back.click
    form.checkbox_1.uncheck
    form.checkbox_2.check
    continue
    expect(page.text).to include(always_content)
    expect(page.text).not_to include(never_content)
    expect(page.text).to include(or_rule)
    expect(page.text).to include(negative_logic_combination)
    expect(page.text).not_to include(checkbox_contains_substring)

    # Check it does catch Option substring
    form.back.click
    form.checkbox_2.uncheck
    form.checkbox_0.check
    continue
    expect(page.text).to include(always_content)
    expect(page.text).not_to include(never_content)
    expect(page.text).to include(and_rule)
    expect(page.text).to include(checkbox_contains_substring)
    expect(page.text).to include(negative_logic_combination)

    # Case we don't answer optional question
    form.back.click
    form.checkbox_0.uncheck
    continue
    expect(page.text).to include(always_content)
    expect(page.text).not_to include(never_content)
    expect(page.text).to include(optional_question_unanswered)
    expect(page.text).to include(negative_logic_combination)

    # Case to check the right side of the logic combination expression
    form.back.click
    form.back.click
    form.radio_b.choose
    continue
    form.checkbox_2.check
    continue
    expect(page.text).to include(always_content)
    expect(page.text).not_to include(never_content)
    expect(page.text).to include(or_rule)
    expect(page.text).to include(negative_logic_combination)
    expect(page.text).to include(logic_combination_content)

    # Checking legacy content is shown
    continue
    expect(page.text).to include(legacy_content)
  end
end
