class FeaturesEmailApp < ServiceApp
  element :start_button, :button, 'Start'
  element :first_name_field, :field, 'First name'
  element :last_name_field, :field, 'Last name'
  element :continue_button, :button, 'Continue'
  element :email_field, :field, 'Your email address'
  element :apples_field, :checkbox, 'Apples', visible: false
  element :pears_field, :checkbox, 'Pears', visible: false
  element :day_field, :field, 'Day'
  element :month_field, :field, 'Month'
  element :year_field, :field, 'Year'
  element :number_cats_field, :field, 'How many cats have chosen you?'
  element :autocomplete_countries_field, :field, 'Where do you like to holiday?'
  element :address_line_1, :field, 'Address line 1'
  element :city, :field, 'Town or city'
  element :postcode, :field, 'Postcode'
end
