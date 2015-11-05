# Industry model
class Industry < GraphStarter::Asset
  property :name, type: String

  has_many :in, :graph_gists, origin: :industries
end
