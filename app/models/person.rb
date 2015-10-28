class Person < GraphStarter::Asset
  has_image

  property :email, type: String
  property :twitter_username, type: String
  property :legacy_id, type: Integer
  property :postal_address, type: String
  property :tshirt_size, type: String
  property :tshirt_size_other, type: String

  def name=(string)
    self.title = string
  end

  def name
    title
  end
end
