class NewRunnerApp < FeaturesEmailApp
  set_url ENV['NEW_RUNNER_APP']

  element :start_button, :button, 'Start now'
  element :yes_field, :radio_button, 'Yes', visible: false
  element :change_optional_checkbox, :link, text: 'Your answer for Optional checkboxes (Optional)', visible: false
  element :change_optional_file_upload, :link, text: 'Your answer for Optional file upload (Optional)', visible: false
  element :remove_file, :link, text: 'Remove file'
  element :delete_file, :link, text: 'hello_world_multi_1.txt', visible: false
  element :add_another, :button, text: 'Add another file'
  element :change_first_name, :link, text: 'Your answer for First name', visible: false
  element :change_last_name, :link, text: 'Your answer for Last name', visible: false
  element :change_email, :link, text: 'Your answer for Your email address', visible: false
  element :change_cat, :link, text: 'Your answer for Your cat', visible: false
  element :change_upload, :link, text: 'Your answer for Upload a file', visible: false
  element :change_autocomplete, :link, text: 'Where do you like to holiday?', visible: false
end
