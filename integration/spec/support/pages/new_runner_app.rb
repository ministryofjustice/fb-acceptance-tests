class NewRunnerApp < FeaturesEmailApp
  set_url ENV.fetch('NEW_RUNNER_APP')

  element :start_button, :button, 'Start now'
  element :yes_field, :radio_button, 'Yes', visible: false
  element :change_optional_checkbox, :link, text: 'Your answer for Optional checkboxes (Optional)', visible: false
  element :change_optional_file_upload, :link, text: 'Your answer for Optional file upload (Optional)', visible: false
  element :remove_file, :link, text: 'Remove file'
end
