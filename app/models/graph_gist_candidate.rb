require 'graph_gist_tools'
require 'open-uri'
require 'faraday_middleware'

class GraphGistCandidate < GraphStarter::Asset
  has_one :out, :graphgist, type: :IS_VERSION, model_class: :GraphGist, unique: true

  property :is_guide, type: Boolean, default: false

  property :title
  property :url, type: String
  property :raw_url, type: String

  property :asciidoc, type: String
  validates :asciidoc, presence: true
  property :raw_html, type: String
  validates :raw_html, presence: true

  property :query_cache, type: String
  validates :query_cache, presence: true
  property :has_errors, type: Boolean, default: false

  property :status, type: String, default: 'candidate'
  enumerable_property :status, %w(live disabled candidate draft)

  has_one :in, :author, type: :WROTE, model_class: :Person

  property :cached, type: Boolean

  display_properties :title, :created_at

  hidden_json_properties :raw_html, :query_cache

  has_many :out, :industries, type: :FOR_INDUSTRY
  has_many :out, :use_cases, type: :FOR_USE_CASE
  has_many :out, :challenges, type: :FOR_CHALLENGE

  category_associations :author, :industries, :use_cases, :graphgist

  body_property :raw_html

  before_validation :place_current_asciidoc, if: :asciidoc_changed?
  before_validation :place_current_url, if: :url_changed?

  json_methods :html, :query_cache_html, :render_id, :persisted?

  validate :is_challenge_active, :check_for_broken_links

  def is_challenge_active
    if challenges.count > 0
      challenges.each do |challenge|
        if challenge.start_date.present? && challenge.start_date > DateTime.now
          errors.add(:challenges, "You can't add graphgists to challenge '#{challenge.name}' because its not started yet")
        elsif challenge.end_date.present? && challenge.end_date < DateTime.now
          errors.add(:challenges, "You can't add graphgists to challenge '#{challenge.name}' because its already ended")
        end
      end
    end
  end

  def place_current_asciidoc
    return if !asciidoc.present?

    place_asciidoc()
    place_query_cache()
  end

  def place_current_url
    place_url(url)

    if !asciidoc.present?
      self.asciidoc = self.class.data_from_url(raw_url) if raw_url.present?
    end

    place_current_asciidoc()
  end

  def place_slug
    self.slug = self.class.unique_slug_from(safe_title + '-candidate')
  end

  def url_is_duplicate?
    self.class.url_is_duplicate?(url)
  end

  def self.url_is_duplicate?(url)
    if !url.present?
      return false
    else
      return !!find_by(url: url)
    end
  end

  SANITIZER = Rails::Html::WhiteListSanitizer.new
  VALID_HTML_TAGS = %w(a b body code col colgroup div em h1 h2 h3 h4 h5 h6 hr html i img li ol p pre span strong style table tbody td th thead tr ul)
  VALID_HTML_ATTRIBUTES = %w(id src href class style data-style graph-mode)

  def place_asciidoc
    document = asciidoctor_document

    place_attributes_from_document!(document)

    place_associations_from_document!(document)
  end

  def asciidoctor_document
    GraphGistTools.asciidoc_document(asciidoc)
  end

  def place_attributes_from_document!(document)
    self.raw_html = SANITIZER.sanitize(self.class.httpsize_img_srces(document.convert),
                                       tags: VALID_HTML_TAGS,
                                       attributes: VALID_HTML_ATTRIBUTES)

    self.raw_html += GraphGistTools.metadata_html(document)

    self.title ||= document.doctitle if document.doctitle.present?
  end

  def place_query_cache
    cypher_blocks = GraphGistTools.cypher_blocks(asciidoctor_document)
    queries = cypher_blocks.map(&:source)
    responses = []
    self.has_errors = false

    client = Neo4jConsole::Neo4jConsoleClient.new(asciidoctor_document.attributes['neo4j-version'])
    client.init
    queries.each do |query|
      response = client.cypher(query)
      response_body = JSON.parse(response.body)
      responses.push response_body
      if response_body.has_key?('error')
        self.has_errors = true
      end
    end
    self.query_cache = responses.to_json
  end

  HOSTS_LOCAL = %w(
    localhost
  )

  def host_is_local?(host)
    HOSTS_LOCAL.any? { |test_host| host.match(/^#{test_host}/) }
  end

  def is_ip?(ip)
    !!IPAddr.new(ip) rescue false
  end

  def is_ip_local?(ip)
    return false if !is_ip?(ip)
    net1 = IPAddr.new("10.0.0.0/8")
    net2 = IPAddr.new("172.16.0.0/12")
    net3 = IPAddr.new("192.168.0.0/16")
    net4 = IPAddr.new("fd00::/8")
    ip_address = IPAddr.new(ip)
    net1 === ip_address or net2 === ip_address or net3 === ip_address or net4 === ip_address
  end

  def check_for_broken_links
    if self.raw_html.empty?
      errors.add(:asciidoc, "raw_html field empty, unable to run check.")
      return nil
    end

    self.raw_html.scan(/(?:href|src)=["'](https?:\/\/[^"']+)["']/im) do |url|
      url = url[0]

      begin
        uri = URI(url)
        next if host_is_local?(uri.host) or is_ip_local?(uri.host)
      rescue URI::InvalidURIError
        errors.add(:asciidoc, "The URL '#{url}' is invalid")
        self.has_errors = true
        next
      end

      begin
        conn = Faraday.new
        res = conn.get do |req|
          req.url url
          req.options.timeout = 30
          req.options.open_timeout = 20
        end
        if res.status >= 400 and res.status < 600
          errors.add(:asciidoc, "The URL '#{url}' is invalid")
          self.has_errors = true
        end
      rescue Faraday::ConnectionFailed
        errors.add(:asciidoc, "The URL '#{url}' is invalid")
        self.has_errors = true
      end
    end
  end

  HOSTS_TRANSFORMABLE_TO_HTTPS = %w(
    i\.imgur\.com
    imgur\.com
    .*\.photobucket\.com
    .*\.postimg\.org
    raw\.github\.com
    raw\.githubusercontent\.com
    .*\.giphy\.com
    .*\.blogspot\.com
    dl\.dropboxusercontent\.com
    www\.dropbox\.com
    docs\.google\.com
  )

  def self.httpsize_img_srces(html)
    doc = Nokogiri::HTML(html)

    img_srcs(doc).each do |src|
      begin
        uri = URI(src.value)
        next if uri.host.nil? || uri.scheme == 'https'

        uri.scheme = 'https' if host_is_httpsizable?(uri.host)

        src.value = uri.to_s
      rescue URI::InvalidURIError
        nil
      end
    end

    doc.xpath('//body').inner_html
  end

  def self.img_srcs(doc)
    doc.xpath('//img').map { |img| img.attribute('src') }.compact
  end

  def self.host_is_httpsizable?(host)
    HOSTS_TRANSFORMABLE_TO_HTTPS.any? { |test_host| host.match(/^#{test_host}$/) }
  end

  def place_associations_from_document!(document)
    if url = document.attributes['thumbnail']
      self.image = GraphStarter::Image.create(source: URI.parse(url), original_url: url)
    end

    twitter, author = document.attributes.values_at('twitter', 'author')
    self.author ||= Person.find_or_create({twitter_username: Person.standardized_twitter_username(twitter)}, name: author) if twitter
  end

  def place_url(new_url)
    self.url = new_url

    self.raw_url = GraphGistTools.raw_url_for(url) if url.present?
  end

  def html
    place_asciidoc if self.raw_html.empty?
    self.raw_html
  end

  def render_id
    id || Digest::SHA256.hexdigest("#{asciidoc}/#{created_at}")
  end

  def query_cache_html
    place_query_cache if self.query_cache.empty?
    return %Q(
      <script>
        var graphgist_cached_queries = #{self.query_cache};
      </script>
    )
  end

  def self.authorized_associations
    @authorized_associations ||= associations.except(*GraphStarter::Asset.associations.keys + [:graphgist, :images, :image])
  end

  def self.create_from_graphgist(graphgist)
    self.create(
      graphgist: graphgist,
      status: graphgist.status,
      title: graphgist.title,
      url: graphgist.url,
      raw_url: graphgist.raw_url,
      asciidoc: graphgist.asciidoc,
      raw_html: graphgist.raw_html,
      cached: graphgist.cached,
      query_cache: graphgist.query_cache,
      author: graphgist.author,
      creators: graphgist.creators,
      created_at: graphgist.created_at,
      updated_at: graphgist.updated_at,
      summary: graphgist.summary,
      is_guide: graphgist.is_guide,
      # image: graphgist.image,
    )
  end

  class << self
    def build_from_url(url)
      asciidoc_text = nil

      t = Benchmark.realtime { asciidoc_text = data_from_url(url) }
      Rails.logger.debug "Retrieved #{url} in #{t.round(1)}s"

      new(asciidoc: asciidoc_text, private: false)
    end

    def data_from_url(url)
      uri = URI(url)

      connection_from_uri(uri).get("#{uri.path}?#{uri.query}").body.force_encoding('UTF-8')
    rescue OpenURI::HTTPError
      nil
    end

    def connection_from_uri(uri)
      Faraday.new("#{uri.scheme}://#{uri.host}:#{uri.port}") do |b|
        b.use FaradayMiddleware::FollowRedirects
        b.adapter :net_http
      end.tap do |conn|
        conn.basic_auth(uri.user, uri.password) if uri.user.present? && uri.password.present?
      end
    end

    def from_graphgist_id(id)
      raw_url = GraphGistTools.raw_url_for_graphgist_id(id)

      return if !raw_url

      GraphGist.find_by(raw_url: raw_url) || GraphGist.new(url: raw_url, title: 'Preview')
    end
  end
end
