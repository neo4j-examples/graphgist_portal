# Industry model
class Industry < GraphStarter::Asset
  has_image

  property :name, type: String

  has_many :in, :graph_gists, origin: :industries

  json_methods :num_graphgists

  def num_graphgists
    self.graph_gists.count()
  end
end
