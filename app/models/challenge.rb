class Challenge < GraphStarter::Asset
  has_image

  property :name, type: String

  property :start_date, type: DateTime
  property :end_date, type: DateTime

  has_many :in, :graph_gists, origin: :challenges

  validate :is_challenge_active

  def is_challenge_active
    if graph_gists.count > 0
      if start_date.present? && start_date > DateTime.now
        errors.add(:graph_gists, "You can't add graphgists to this challenge because its not started yet")
      elsif end_date.present? && end_date < DateTime.now
        errors.add(:graph_gists, "You can't add graphgists to this challenge because its already ended")
      end
    end
  end
end
