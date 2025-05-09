describe 'Conditional Content' do
  let(:form) { ConditionalContentV2App.new }

  let(:always_content) { 'This is always shown' }
  let(:never_content) { 'This is never shown' }
  let(:logic_combination_content) { 'If radio is a && checkbox is 1 OR radio is b && checkbox is 2' }
  let(:negative_logic_combination) { 'If radio is not a OR checkbox is not Option 1 OR checkbox is not Option 2' }
  let(:checkbox_contains_substring) { 'If checkbox contains Option, it should not show if Option 1 or Option 2' }
  let(:optional_question_unanswered) { 'If checkbox is not answered' }
  let(:if_this_or_this_and_that) { 'If radio is a OR radio is b && checkbox is 1 && 2' }
  let(:and_rule) { 'If radio a && checkbox Option 1' }
  let(:or_rule) { 'If radio b II checkbox Option 2' }
  let(:legacy_content) { 'This is legacy conditional content that should be picked up by default' }

  before { form.load }

  it 'shows appropriate conditional content depending on users answers' do
    form.start_now_button.click
    sleep 2
    form.radio_a.choose
    continue
    sleep 2
    form.checkbox_1.check
    continue
    sleep 1
    expect(page.text).to include(always_content)
    expect(page.text).not_to include(never_content)
    expect(page.text).to include(and_rule)
    expect(page.text).to include(logic_combination_content)
    expect(page.text).to include(if_this_or_this_and_that)

    # Check with negative logic
    form.back.click
    sleep 1
    form.checkbox_1.uncheck
    form.checkbox_2.check
    continue
    sleep 1
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
    sleep 1
    expect(page.text).to include(always_content)
    expect(page.text).not_to include(never_content)
    expect(page.text).to include(checkbox_contains_substring)
    expect(page.text).to include(negative_logic_combination)

    # Case we don't answer optional question
    form.back.click
    form.checkbox_0.uncheck
    continue
    sleep 1
    expect(page.text).to include(always_content)
    expect(page.text).not_to include(never_content)
    expect(page.text).to include(optional_question_unanswered)
    expect(page.text).to include(negative_logic_combination)

    # Case to check the right side of the logic combination expression
    form.back.click
    form.back.click
    form.radio_b.choose
    continue
    sleep 1
    form.checkbox_2.check
    continue
    sleep 1
    expect(page.text).to include(always_content)
    expect(page.text).not_to include(never_content)
    expect(page.text).not_to include(if_this_or_this_and_that) # if b is true, but and option 1 and option two are not
    expect(page.text).to include(or_rule)
    expect(page.text).to include(negative_logic_combination)
    expect(page.text).to include(logic_combination_content)

    # Check complex logic if b and checkbox 1 and 2
    form.back.click
    form.checkbox_1.check # radio is now b, checkbox 1 and 2 are checked
    continue
    sleep 1
    expect(page.text).to include(logic_combination_content)

    # Checking legacy content is shown
    continue
    sleep 1
    expect(page.text).to include(legacy_content)
  end
end
