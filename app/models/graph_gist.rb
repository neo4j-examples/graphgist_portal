require 'graph_gist_tools'
require 'open-uri'

class GraphGist < GraphStarter::Asset
  has_image
  rated

  property :title
  property :url, type: String, constraint: :unique
  property :raw_url, type: String

  property :asciidoc, type: String
  validates :asciidoc, presence: true
  property :html, type: String
  validates :html, presence: true

  property :status, type: String
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

  category_associations :author, :industries, :use_cases

  body_property :html

  before_validation :place_updated_url, if: :url_changed?

  def place_updated_url
    place_url(url)
    place_asciidoc(open(raw_url).read) if raw_url.present?
  end

  after_create :notify_admins_about_creation

  def notify_admins_about_creation
    GraphGistMailer.notify_admins_about_creation(self).deliver_now
  end

  VALID_HTML_TAGS = %w(a b body code col colgroup div em h1 h2 h3 h4 h5 h6 hr html i img li ol p pre span strong table tbody td th thead tr ul)
  VALID_HTML_ATTRIBUTES = %w(id class style data-style)
  def place_asciidoc(asciidoc_text)
    write_attribute(:asciidoc, asciidoc_text)

    GraphGistTools.asciidoc_document(asciidoc).tap do |document|
      sanitizer = Rails::Html::WhiteListSanitizer.new

      self.html = sanitizer.sanitize(document.convert,
                                     tags: VALID_HTML_TAGS,
                                     attributes: VALID_HTML_ATTRIBUTES)
      self.html += GraphGistTools.metadata_html(document)

      self.title = document.doctitle if document.doctitle.present?
    end
  end

  def place_url(new_url)
    self.url = new_url

    self.raw_url = GraphGistTools.raw_url_for(url) if url.present?
  end

  class << self
    def build_from_url(url)
      asciidoc_text = nil

      t = Benchmark.realtime do
        asciidoc_text = open(url).read
      end
      Rails.logger.debug "Retrieved #{url} in #{t.round(1)}s"

      new(asciidoc: asciidoc_text, private: false)
    end
  end
end
