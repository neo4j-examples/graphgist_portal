# Mailers for everything to do with GraphGists
class GraphGistMailer < ApplicationMailer
  def notify_admins_about_creation(graphgist)
    @graphgist = graphgist

    admin_emails = User.where(admin: true).pluck(:email).compact.map(&:downcase).uniq

    mail to: admin_emails,
         subject: "[New GraphGist] #{@graphgist.title}"
  end

  def thanks_for_submission(_graphgist, _user)
  end
end
