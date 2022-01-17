class NewRunnerBranchingApp < ServiceApp
  set_url ENV.fetch('NEW_RUNNER_BRANCHING_APP')

  element :page_a_field, :field, 'Page A'

  element :option_1, :checkbox, 'Option 1', visible: false
  element :option_2, :checkbox, 'Option 2', visible: false
  element :option_3, :checkbox, 'Option 3', visible: false

  element :page_c_field, :field, 'Page C'
  element :page_d_field, :field, 'Page D'
  element :page_e_field, :field, 'Page E'

  element :option_a, :checkbox, 'Option A', visible: false
  element :option_b, :checkbox, 'Option B', visible: false
  element :option_c, :checkbox, 'Option C', visible: false
  element :option_d, :checkbox, 'Option D', visible: false

  element :page_l_field, :field, 'Page L'

  element :change_page_b_answer, :link, text: 'Your answer for Page B', visible: false
  element :change_page_j_answer, :link, text: 'Your answer for Page J', visible: false
end
