describe 'Conditional Content' do
  let(:form) { ConditionalContentV2App.new }
  let(:always_content) { 'This is always shown' }
  let(:never_content) { 'This is never shown' }
  let(:logic_combination_content) { 'If radio is a && checkbox is 1 OR radio is b && checkbox is 2' }
  let(:negative_logic_combination) { 'If radio is not a OR checkbox is not Option 1 OR checkbox is not Option 2' }
  let(:checkbox_contains_substring) { 'If checkbox contains Option, it should not show if Option 1 or Option 2' }

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
    expect(page.text).to include('If radio a && checkbox Option 1')
    expect(page.text).to include(logic_combination_content)

    form.back.click
    form.checkbox_1.uncheck
    form.checkbox_2.check
    continue
    expect(page.text).to include(always_content)
    expect(page.text).not_to include(never_content)
    expect(page.text).to include('If radio b II checkbox Option 2')
    expect(page.text).to include(negative_logic_combination)
    expect(page.text).not_to include(checkbox_contains_substring)

    form.back.click
    form.checkbox_2.uncheck
    form.checkbox_0.check
    continue
    expect(page.text).to include(always_content)
    expect(page.text).not_to include(never_content)
    expect(page.text).to include('If radio a && checkbox Option 1')
    expect(page.text).to include(checkbox_contains_substring)
    expect(page.text).to include(negative_logic_combination)
  end
end
