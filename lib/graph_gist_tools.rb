require 'json'
require 'open-uri'
require 'faraday'

require 'action_controller'

module GraphGistTools
  ASCIIDOC_ATTRIBUTES = ['env-graphgist']

  # ActionController::Base.helpers.image_url('loading.gif')

  loading_image_tag = '<img src="' + ActionController::Base.asset_host.to_s + '/images/loading.gif" style="width: 30px">'

  COMMENT_REPLACEMENTS = {
    console: '<p class="console"><span class="loading">' + loading_image_tag + ' Running queries, preparing the console!</span></p>',

    graph_result: '<h5 class="graph-visualization" data-style="{style}" graph-mode="result">' + loading_image_tag + '</h5>',
    graph: '<h5 class="graph-visualization" data-style="{style}">Loading graph...' + loading_image_tag + '</h5>',
    table: '<h5 class="result-table">Loading table...' + loading_image_tag + '</h5>',

    hide: '<span class="hide-query"></span>',
    setup: '<span class="setup"></span>',
    output: '<span class="query-output"></span>'
  }

  def self.asciidoc_document(asciidoc_text)
    text = asciidoc_text.dup
    COMMENT_REPLACEMENTS.each do |tag, replacement|
      prefix = nil
      prefix = "\n\n[subs=\"attributes\"]\n" if [:graph_result, :graph].include?(tag)
      text.gsub!(Regexp.new(%r{^//\s*#{tag}}, 'gm'), "#{prefix}++++\n#{replacement}\n++++\n")
    end

    Asciidoctor.load(text, attributes: ASCIIDOC_ATTRIBUTES)
  end

  def self.metadata_html(asciidoc_doc)
    attrs = asciidoc_doc.attributes

    <<-METADATA
<span id="metadata" author="#{attrs['author']}" version="#{attrs['neo4j-version']}" twitter="#{attrs['twitter']}" tags="#{attrs['tags']}" />
METADATA
  end

  #   let_context url: 'http://github.com/neo4j-examples/graphgists/blob/master/fraud/bank-fraud-detection.adoc' do
  #     it { should eq 'https://raw.githubusercontent.com/neo4j-examples/graphgists/master/fraud/bank-fraud-detection.adoc' }

  def self.raw_url_for(url) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
    case url.strip
    when %r{^https?://gist\.github\.com/([^/]+/)?(.+)$}
      url_from_github_graphgist_api($2)
    when %r{^https?://gist\.neo4j\.org/\?(.+)$}
      raw_url_for_graphgist_id($1)
    when %r{^https?://(www\.)?github\.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)/?$}
      raw_url_from_github_api($2, $3, $5, $4)
    when %r{^https?://(www\.)?dropbox\.com/s/([^/]+)/([^\?]+)(\?dl=(0|1))?$}
      "https://www.dropbox.com/s/#{$2}/#{$3}?dl=1"
    when %r{^https?://docs.google.com/document/d/([^\/]+)(/edit)?$}
      "https://docs.google.com/document/u/0/export?format=txt&id=#{$1}"
    when %r{^(https?://[^/]*etherpad[^/]*/([^/]+/)*)p/([^/]+)/?$}
      "#{$1}p/#{$3}/export/txt"
    when %r{^https?://(www.)?pastebin.com/([^/]+)/?$}
      "http://pastebin.com/raw.php?i=#{$2}"
    else
      url if url_returns_text_content_type?(url)
    end
  end

  def self.url_returns_text_content_type?(url)
    http_connection = Faraday.new url: url
    result = http_connection.head url
    result.headers['content-type'].match(%r{^text/})
  rescue URI::InvalidURIError, Faraday::ConnectionFailed
    nil
  end

  def self.raw_url_for_graphgist_id(graphgist_id)
    id = URI.decode(graphgist_id)
    case id
    when /^github-(.*)$/
      parts = $1.split('/')
      raw_url_from_github_api(parts[0], parts[1], parts[3..-1].join('/'))
    when /^dropbox(s?)-(.*)$/
      is_private = !$1.empty?
      "https://dl.dropboxusercontent.com/#{is_private ? 's' : 'u'}/#{$2}"
    when /^copy-(.*)$/
      "https://copy.com/#{$1}?download=1"
    when /^https?/
      id
    else
      url_from_github_graphgist_api(id)
    end
  end

  def self.github_api_headers
    {}.tap do |headers|
      headers['Authorization'] = "token #{ENV['GITHUB_TOKEN']}" if ENV['GITHUB_TOKEN']
    end
  end

  def self.raw_url_from_github_api(owner, repo, path, branch = 'master')
    begin
      url = "https://api.github.com/repos/#{owner}/#{repo}/contents/#{path}?ref=#{branch}"
      data = JSON.load(open(url, github_api_headers).read)
    rescue OpenURI::HTTPError
      puts "WARNING: Error trying to fetch: #{url}"
      return nil
    end

    data['download_url']
  end

  def self.url_from_github_graphgist_api(id)
    begin
      url = "https://api.github.com/gists/#{id}"
      data = JSON.load(open(url, github_api_headers).read)
    rescue OpenURI::HTTPError
      puts "WARNING: Error trying to fetch: #{url}"
      return nil
    end

    fail ArgumentError, 'Gist has more than one file!' if data['files'].size > 1

    data['files'].to_a[0][1]['raw_url']
  end
end
