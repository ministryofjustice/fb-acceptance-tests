require 'pdf-reader'
require 'csv'

describe 'New Runner Branching App' do
  let(:form) { NewRunnerBranchingApp.new }

  let(:page_a_answer) { "FN-#{SecureRandom.uuid}" }
  let(:page_b_answer) { 'Page B Option 1' }
  let(:page_b_changed_answer) { 'Page B Option 2' }
  let(:page_c_answer) { "FN-#{SecureRandom.uuid}" }
  let(:page_d_answer) { "FN-#{SecureRandom.uuid}" }
  let(:page_e_answer) { "FN-#{SecureRandom.uuid}" }
  let(:page_f_answer) { 'Page F Option B' }
  let(:page_l_answer) { "FN-#{SecureRandom.uuid}" }
  let(:page_i_answer) { 'Page I Option 1' }
  let(:page_j_answer) { 'Page J Option 2' }
  let(:error_message) { 'There is a problem' }

  before { form.load }

  it 'navigates the form, changes answers and submits' do
    form.start_now_button.click

    # page-a
    check_optional_text(page.text)
    continue
    check_error_message(page.text, [form.find('h1').text])
    form.page_a_field.set(page_a_answer)
    continue

    # page-b
    check_optional_text(page.text)
    continue
    check_error_message(page.text, [form.find('h1').text])
    form.option_1.check
    continue

    # page-c
    check_optional_text(page.text)
    continue
    check_error_message(page.text, [form.find('h1').text])
    form.page_c_field.set(page_c_answer)
    continue

    # page-d
    check_optional_text(page.text)
    continue
    check_error_message(page.text, [form.find('h1').text])
    form.page_d_field.set(page_d_answer)
    continue

    # page-e
    check_optional_text(page.text)
    continue
    check_error_message(page.text, [form.find('h1').text])
    form.page_e_field.set(page_e_answer)
    continue

    # page-f
    check_optional_text(page.text)
    continue
    check_error_message(page.text, [form.find('h1').text])
    form.option_b.check
    continue

    # page-l
    check_optional_text(page.text)
    continue
    check_error_message(page.text, [form.find('h1').text])
    form.page_l_field.set(page_l_answer)
    continue

    # check your answers
    check_optional_text(page.text)
    expect(page_answer('Page A')).to include(page_a_answer)
    expect(page_answer('Page B')).to include(page_b_answer)
    expect(page_answer('Page C')).to include(page_c_answer)
    expect(page_answer('Page D')).to include(page_d_answer)
    expect(page_answer('Page E')).to include(page_e_answer)
    expect(page_answer('Page F')).to include(page_f_answer)
    expect(page_answer('Page L')).to include(page_l_answer)

    # change page b answer
    form.change_page_b_answer.click
    form.option_1.uncheck
    form.option_2.check
    continue

    # page-i
    check_optional_text(page.text)
    continue
    check_error_message(page.text, [form.find('h1').text])
    form.option_1.check
    continue

    # page-j
    check_optional_text(page.text)
    form.option_2.check
    continue

    # check your answers
    check_optional_text(page.text)
    expect(page_answer('Page A')).to include(page_a_answer)
    expect(page_answer('Page B')).to include(page_b_changed_answer)
    expect(page_answer('Page I')).to include(page_i_answer)
    expect(page_answer('Page J (Optional)')).to include(page_j_answer)
    # Old answers from different path should no longer be there
    expect(page.text).not_to include(page_c_answer)
    expect(page.text).not_to include(page_d_answer)
    expect(page.text).not_to include(page_e_answer)
    expect(page.text).not_to include(page_f_answer)
    expect(page.text).not_to include(page_l_answer)

    # change page j answer
    form.change_page_j_answer.click
    form.option_2.uncheck
    continue

    # page f
    continue

    # page l
    continue

    # check your answers should remember previously answered questions
    check_optional_text(page.text)
    expect(page_answer('Page A')).to include(page_a_answer)
    expect(page_answer('Page B')).to include(page_b_changed_answer)
    expect(page_answer('Page I')).to include(page_i_answer)
    # we removed Page J answer as it is optional
    expect(page_answer('Page J (Optional)')).to be_empty
    expect(page_answer('Page F')).to include(page_f_answer)
    expect(page_answer('Page L')).to include(page_l_answer)
    # does not include older answers from different path
    expect(page.text).not_to include(page_c_answer)
    expect(page.text).not_to include(page_d_answer)
    expect(page.text).not_to include(page_e_answer)

    form.submit_button.click

    expect(form.text).to include('Application complete')

    # pdf_attachments = find_pdf_attachments(id: page_a_answer, expected_emails: 1)
    # csv_attachments = find_csv_attachments(id: page_a_answer)
    # assert_pdf_contents(pdf_attachments)
    # assert_csv_contents(csv_attachments)
  end

  def assert_pdf_contents(attachments)
    pdf_path = "/tmp/submission-#{SecureRandom.uuid}.pdf"
    File.open(pdf_path, 'w') do |file|
      file.write(attachments[:pdf_answers])
    end
    result = PDF::Reader.new(pdf_path).pages.map do |page|
      page.text
    end.join(' ')
    p 'Asserting PDF contents'

    expect(result).to include(
      'Submission subheading for Acceptance Tests'
    )
    expect(result).to include(
      'Submission for Acceptance Tests'
    )

    expect(result).to include(page_a_answer)
    expect(result).to include(page_b_changed_answer)
    expect(result).to include(page_i_answer)
    # we removed Page J answer as it is optional
    expect(result).to_not include(page_j_answer)
    expect(result).to include(page_f_answer)
    expect(result).to include(page_l_answer)
    # does not include older answers from different path
    expect(result).not_to include(page_c_answer)
    expect(result).not_to include(page_d_answer)
    expect(result).not_to include(page_e_answer)
    # optional text
    check_optional_text(result)
  end

  def assert_csv_contents(attachments)
    content = attachments[:csvs].first || ""
    csv_path = "/tmp/submission-#{SecureRandom.uuid}.csv"
    File.open(csv_path, 'w') do |file|
      file.write(content)
    end
    rows = CSV.read(csv_path)

    p 'Asserting CSV contents'

    expect(rows[0]).to match_array([
      'submission_id',
      'submission_at',
      'page-a_text_1',
      'page-b_checkboxes_1',
      'destinationb_checkboxes_1',
      'page-j_checkboxes_1',
      'page-f_checkboxes_1',
      'page-l_text_1'
    ])

    expect(rows[1][0]).to match(/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/) # guid
    expect(rows[1][1]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z/) # iso timestamp

    expect(rows[1][2..]).to match_array([
      page_a_answer,
      page_b_changed_answer,
      page_i_answer,
      '',
      page_f_answer,
      page_l_answer
    ])
  end

  def summary_list
    page.all('.govuk-summary-list .govuk-summary-list__row')
  end

  def page_answer(page_key)
    answer = summary_list.find { |row| row.find('dt.govuk-summary-list__key').text == page_key }
    answer.find('dd.govuk-summary-list__value').text
  end
end
