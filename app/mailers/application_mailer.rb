# Base for all mailers in the application
class ApplicationMailer < ActionMailer::Base
  default from: 'graphgist_portal@graphgist.org', reply_to: 'devrel@neo4j.com'
end
