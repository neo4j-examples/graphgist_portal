require 'graph_gist_tools'
require 'open-uri'

class GraphGist < GraphStarter::Asset
  has_image
  rated

  property :title
  property :url, type: String, constraint: :unique
  validates :url, uniqueness: {message: 'already in use'}
  property :raw_url, type: String
  validates :raw_url, presence: {message: 'URL could not be resolved'}

  property :asciidoc, type: String
  validates :asciidoc, presence: true
  property :raw_html, type: String
  validates :raw_html, presence: true

  property :status, type: String, default: 'candidate'
  enumerable_property :status, %w(live disabled candidate)

  has_one :in, :author, type: :WROTE, model_class: :Person

  property :legacy_id, type: String
  property :legacy_neo_id, type: Integer
  property :legacy_poster_image, type: String
  property :legacy_rated, type: String

  display_properties :url, :created_at


  property :featured, type: Boolean

  scope :only_featured, -> { where(featured: true) }

  has_many :out, :industries, type: :FOR_INDUSTRY
  has_many :out, :use_cases, type: :FOR_USE_CASE

  has_one :out, :challenge_category, type: :FOR_CHALLENGE_CATEGORY, model_class: :UseCase

  category_associations :author, :industries, :use_cases

  body_property :raw_html

  before_validation :place_current_url, if: :url_changed?

  def place_current_url
    place_url(url)
    return if !raw_url.present?

    text = self.class.data_from_url(raw_url)

    place_asciidoc(text) if text
  end

  after_create :notify_admins_about_creation

  def notify_admins_about_creation
    # GraphGistMailer.notify_admins_about_creation(self).deliver_now
  end

  SANITIZER = Rails::Html::WhiteListSanitizer.new
  VALID_HTML_TAGS = %w(a b body code col colgroup div em h1 h2 h3 h4 h5 h6 hr html i img li ol p pre span strong table tbody td th thead tr ul)
  VALID_HTML_ATTRIBUTES = %w(id src class style data-style)
  def place_asciidoc(asciidoc_text)
    self.asciidoc = asciidoc_text

    document = asciidoctor_document

    self.raw_html = SANITIZER.sanitize(document.convert,
                                       tags: VALID_HTML_TAGS,
                                       attributes: VALID_HTML_ATTRIBUTES)
    self.raw_html += GraphGistTools.metadata_html(document)

    self.title = document.doctitle if document.doctitle.present?

    twitter, author = document.attributes.values_at('twitter', 'author')
    self.author ||= Person.find_or_create({twitter_username: Person.standardized_twitter_username(twitter)}, name: author) if twitter
  end

  def asciidoctor_document
    GraphGistTools.asciidoc_document(asciidoc)
  end

  def place_url(new_url)
    self.url = new_url

    self.raw_url = GraphGistTools.raw_url_for(url) if url.present?
  end

  def html
    place_current_url if status == 'candidate'

    self.raw_html
  end

  class << self
    def build_from_url(url)
      asciidoc_text = nil

      t = Benchmark.realtime do
        asciidoc_text = data_from_url(url)
      end
      Rails.logger.debug "Retrieved #{url} in #{t.round(1)}s"

      new(asciidoc: asciidoc_text, private: false)
    end

    def data_from_url(url)
      open(url).read
    rescue OpenURI::HTTPError
      nil
    end
  end
end
