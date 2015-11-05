# Use case model
class UseCase < GraphStarter::Asset
  property :name, type: String

  has_many :in, :graph_gists, origin: :use_cases
end
