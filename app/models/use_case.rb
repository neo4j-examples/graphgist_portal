# Use case model
class UseCase < GraphStarter::Asset
  has_image

  property :name, type: String

  has_many :in, :graph_gists, origin: :use_cases

  json_methods :num_graphgists

  def num_graphgists
    self.graph_gists.count()
  end
end
