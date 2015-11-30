class Person < GraphStarter::Asset
  has_image

  property :name, type: String
  property :email, type: String
  property :twitter_username, type: String
  property :legacy_id, type: Integer
  property :legacy_neo_id, type: Integer
  property :postal_address, type: String
  property :tshirt_size, type: String
  property :tshirt_size_other, type: String

  display_properties :name, :twitter_username

  has_many :out, :authored_gists, origin: :author, model_class: :GraphGist

  has_one :in, :user, origin: :person

  before_validation :standardize_twitter_username

  def standardize_twitter_username
    self.twitter_username = self.class.standardized_twitter_username(twitter_username)
  end

  def self.standardized_twitter_username
    twitter_username.match(/^@\w/) ? twitter_username[1..-1] : twitter_username
  end
end
