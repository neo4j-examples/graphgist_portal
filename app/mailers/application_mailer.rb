# Base for all mailers in the application
class ApplicationMailer < ActionMailer::Base
  default from: 'graphgist_portal@neo4j.com' # DOES NOT YET EXIST
  #  layout 'mailer'
end
