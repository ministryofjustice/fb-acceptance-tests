describe 'Conditional Content' do
  let(:form) { ConditionalContentV2App.new }
  let(:always_content) { 'This is always shown' }
  let(:never_content) { 'This is never shown' }
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
    expect(page.text).to include('If radio a && checkbox Option 1')
    expect(page.text).to include('If radio is a && checkbox is 1 OR radio is b && checkbox is 2')
    continue
    expect(page.text).to include(legacy_content)
  end
end
