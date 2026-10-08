class FeaturesJsonSubmissionApiApp < FeaturesEmailApp
  set_url ENV['JSON_SUBMISSION_API_V2_APP']

  element :start_button, :button, 'Start now'
  element :option_Bertha, :checkbox, 'Bertha Benz', visible: false
  element :option_Margaret, :checkbox, 'Margaret Wilcox', visible: false
  element :question, :field, 'Answer to the Ultimate Question of Life, the Universe, and Everything'
  element :proof, :field, 'Proof supporting your solution'
  element :day, :field, 'Day'
  element :month, :field, 'Month'
  element :year, :field, 'Year'
  element :option_Others, :radio_button, 'Others', visible: false
end
