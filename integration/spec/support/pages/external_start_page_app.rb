class ExternalStartPageApp < FeaturesEmailApp
  set_url ENV['EXTERNAL_START_PAGE_APP']

  element :question_1, :field, 'First question'
end
