require 'spec_helper'

describe 'API Submission' do
  let(:form) { FeaturesJsonSubmissionApiApp.new }
  let(:filename1) { 'hello_world.txt' }
  let(:filename2) { 'goodbye_world.txt' }

  before { form.load }

  it 'sends an API submission' do
    form.start_now_button.click
    check_optional_text(page.text)
    form.option_Bertha.check
    form.option_Margaret.check
    continue
    form.question.set('42')
    continue
    form.proof.set('The web')
    form.day.set('01')
    form.month.set('01')
    form.year.set('1111')
    form.option_Others.choose
    continue
    attach_file('Attachment 1', 'spec/fixtures/files/hello_world.txt')
    continue
    attach_file('Attachment 2', 'spec/fixtures/files/goodbye_world.txt')
    continue
    form.submit_button.click

    expect(page.text).to include('Application complete')
    result = wait_for_request
    expect(result).to have_key(:submissionId)
    expect(result[:serviceSlug]).to eq('json-acceptance-test')
    expect(result[:submissionAnswers][:win_checkboxes_1]).to eq('Bertha Benz; Margaret Wilcox')
    expect(result[:submissionAnswers][:question_text_1]).to eq('42')
    expect(result[:submissionAnswers][:multiple_text_1]).to eq('The web')
    expect(result[:submissionAnswers][:multiple_date_1]).to eq('01 January 1111')
    expect(result[:submissionAnswers][:multiple_radios_1]).to eq('Others')
    expect(result[:submissionAnswers][:attachment_upload_1]).to eq(filename1)
    expect(result[:submissionAnswers][:attachment2_upload_1]).to eq(filename2)
    expect(result[:attachments].size).to eql(2)
    expect(result[:attachments][0][:filename]).to eq(filename1)
    expect(result[:attachments][1][:filename]).to eq(filename2)
    expect(result[:attachments][0][:encryption_iv].size).to eql(24)
    expect(result[:attachments][0][:encryption_key].size).to eql(44)
    expect(result[:attachments][0][:filename]).to eql('hello_world.txt')
    expect(result[:attachments][0][:mimetype]).to eql('text/plain')

    file_contents = URI.open(result[:attachments][0][:url], 'rb').read

    crypto = Cryptography.new(
      encryption_key: Base64.strict_decode64(result[:attachments][0][:encryption_key]),
      encryption_iv: Base64.strict_decode64(result[:attachments][0][:encryption_iv])
    )

    decrypted_file_contents = crypto.decrypt(file: file_contents)

    expect(decrypted_file_contents).to eql("hello world\n")
    expect(result[:attachments][1][:encryption_iv].size).to eql(24)
    expect(result[:attachments][1][:encryption_key].size).to eql(44)
    expect(result[:attachments][1][:filename]).to eql('goodbye_world.txt')
    expect(result[:attachments][1][:mimetype]).to eql('text/plain')

    delete_adapter_submissions
  end
end
