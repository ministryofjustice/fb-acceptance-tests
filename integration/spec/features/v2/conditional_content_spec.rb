describe 'Conditional Content' do
  let(:form) { ConditionalContentV2App.new }
  let(:always_content) { 'This is always shown' }

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
  end
end
