# Use case model
class UseCase < GraphStarter::Asset
  has_image

  property :name, type: String
  property :for_challenge, type: Boolean

  #  scope :for_challenge, -> { where(for_challenge: true) }

  has_many :in, :graph_gists, origin: :use_cases
end
