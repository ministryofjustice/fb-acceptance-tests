class FeaturesEmailApp < SitePrism::Page
  set_url ENV.fetch('FEATURES_EMAIL_APP_PORT')

  element :start_button, :button, 'Start'
  element :first_name_field, :field, 'First name'
  element :last_name_field, :field, 'Last name'
  element :continue_button, :button, 'Continue'
  element :has_email_field, :radio_button, 'Yes', visible: false
  element :email_field, :field, 'Your email address'
  element :apples_field, :checkbox, 'Apples', visible: false
  element :pears_field, :checkbox, 'Pears', visible: false
  element :day_field, :field, 'Day'
  element :month_field, :field, 'Month'
  element :year_field, :field, 'Year'
  element :number_cats_field, :field, 'How many cats have chosen you?'
  element :cat_spy_field, :select, 'Is your cat watching you now?'
  element :autocomplete_field, '#page_autocomplete--autocomplete_autocomplete', visible: false
  element :cat_picture_field, :file_field, 'What does your cat look like?'
  element :confirm_upload_field, :radio_button, 'Yes, add this upload', visible: false
end
