require "selenium-webdriver"
require 'byebug' # Byebug gem is used for debugging

# Search in https://rubygems.org/
def search query
  # Create headless browser and navigate to https://rubygems.org
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  browser = Selenium::WebDriver.for :chrome, options: options
  browser.navigate.to "https://rubygems.org"

  # Get the search form
  form = browser.find_element css: 'form[action="/search"]'

  # Search the query input and set it's value
  query_field = form.find_element name: 'query'
  browser.execute_script "return arguments[0].value = '#{query}'", query_field

  # Submit the form
  form.submit

  # Extract results from HTML and return
  browser.page_source.scan /gems__gem__name[^\>]+\>\s+(.+?)\s+\</i
end

# Uncomment the next line "byebug" to start debugging the app
#byebug
# Search the 'rails' gem and print the results HTML
puts search 'rails'
