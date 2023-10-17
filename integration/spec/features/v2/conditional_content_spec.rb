describe 'Conditional Content' do
  let(:form) { ConditionalContentV2App.new }

  before { form.load }
  # comment above line and uncomment below and export user and password ENV vars for local testing
  # before { visit "https://#{username}:#{password}@new-runner-acceptance-tests.dev.test.form.service.justice.gov.uk" }

  it 'shows appropriate conditional content depending on user answers' do

  end
end
