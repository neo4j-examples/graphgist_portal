# Industry model
class Industry < GraphStarter::Asset
  has_image

  property :name, type: String

  has_many :in, :graph_gists, origin: :industries
end
