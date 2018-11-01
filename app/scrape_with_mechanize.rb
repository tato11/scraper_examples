require 'rubygems'
require 'mechanize'
require 'byebug' # Byebug gem is used for debugging

# Search in https://rubygems.org/
def search query
  # Create headless browser and navigate to https://rubygems.org
  browser = Mechanize.new
  page = browser.get 'https://rubygems.org'

  # Get the search form
  form = page.form_with action: '/search'

  # Search the query input and set it's value
  query_field = form.fields.select{|field| field.name == 'query'}.first
  query_field.value = query

  # Submit the form
  page = form.submit

  # Extract results from HTML and return
  page.body.scan /gems__gem__name[^\>]+\>\s+(.+?)\s+\</i
end

# Uncomment the next line "byebug" to start debugging the app
#byebug
# Search the 'rails' gem and print the results HTML
puts search 'rails'
