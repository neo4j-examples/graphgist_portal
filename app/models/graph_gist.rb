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
  validates :status, inclusion: {in: %w(live disabled candidate)}

  has_one :in, :author, type: :WROTE, model_class: :Person

  property :legacy_id, type: String
  property :legacy_neo_id, type: Integer
  property :legacy_poster_image, type: String
  property :legacy_rated, type: String

  display_properties :url, :created_at

  VALID_HTML_TAGS = %w(a b body code col colgroup div em h1 h2 h3 h4 h5 h6 hr html i img li ol p pre span strong table tbody td th thead tr ul)
  VALID_HTML_ATTRIBUTES = %w(id class style)
  def place_asciidoc(asciidoc_text)
    write_attribute(:asciidoc, asciidoc_text)

    GraphGistTools.asciidoc_document(asciidoc).tap do |document|
      sanitizer = Rails::Html::WhiteListSanitizer.new

      self.html = sanitizer.sanitize(document.convert,
                                     tags: VALID_HTML_TAGS,
                                     attributes: VALID_HTML_ATTRIBUTES)

      self.title = document.doctitle
    end
  end

  def url=(new_url)
    super

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
