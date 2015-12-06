require 'faraday'

When(/^The URL ([^ ]+) is visited$/) do |url|
  @response = Faraday.get(url)
end

When(/^The path ([^ ]+) is visited$/) do |url|
  @response = Faraday.get($host + url)
end


Then(/^A redirect is given to ([^ ]+)$/) do |url|
  expect(@response.status).should == 301
  expect(@response.headers['location']).should == url
end

Then(/^A page with "([^"]*)" is returned$/) do |text|
  expect(@response.body).to include(text)
end

