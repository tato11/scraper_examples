require 'rubygems'
require 'typhoeus'
require 'byebug' # Byebug gem is used for debugging

# Search in https://rubygems.org/
def search query
  # Typhoeus is a equivalent to use curl command in a terminal
  # Search directly on https://rubygems.org by sending the query as query_string parameters
  request = Typhoeus::Request.new 'https://rubygems.org/search', params: {
    query: query
  }
  page = request.run

  # Extract results from HTML and return
  page.body.scan /gems__gem__name[^\>]+\>\s+(.+?)\s+\</i
end

# Uncomment the next line "byebug" to start debugging the app
#byebug
# Search the 'rails' gem and print the results HTML
puts search 'rails'
