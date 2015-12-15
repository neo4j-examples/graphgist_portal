require 'faraday'

When(/^The URL ([^ ]+) is visited$/) do |url|
  @response = Faraday.get(url)
end

When(/^The path ([^ ]+) is visited$/) do |url|
  @response = Faraday.get(RailsGraphgistPortal.host + url)
end


Then(/^A redirect is given to ([^ ]+)$/) do |url|
  expect(@response.status).to eq 301
  expect(@response.headers['location']).to eq url
end

Then(/^A page with "([^"]*)" is returned$/) do |text|
  expect(@response.body).to include(text)
end

Then(/^JSON is returned having a key '([^']+)' which contains '([^']+)'$/) do |key, text|
  data = JSON.parse(@response.body)
  expect(data[key]).to include(text)
end

