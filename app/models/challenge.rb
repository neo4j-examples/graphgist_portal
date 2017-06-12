class Challenge < GraphStarter::Asset
  has_image

  property :name, type: String

  property :start_date, type: DateTime
  property :end_date, type: DateTime

  has_many :in, :graph_gists, type: :FOR_CHALLENGE

  #scope :only_active, -> { where('start_date <= {now} AND end_date >= {now}', now: DateTime.now) }

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

  def self.only_active
    where('(result_challenge.start_date IS NULL OR result_challenge.start_date <= {now}) AND (result_challenge.end_date IS NULL OR result_challenge.end_date >= {now})', now: DateTime.now.to_i)
  end
end
