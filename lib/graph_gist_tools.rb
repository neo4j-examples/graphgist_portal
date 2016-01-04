require 'json'
require 'open-uri'
require 'faraday'

require 'action_controller'

module GraphGistTools
  class InvalidGraphGistIDError < StandardError; end

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
      prefix = [:graph_result, :graph].include?(tag) ? "\n\n[subs=\"attributes\"]\n" : nil

      text.gsub!(Regexp.new(%r{^//\s*#{tag}}, 'gm'), "#{prefix}++++\n#{replacement}\n++++\n")
    end

    text = replace_doc_with_macro(text)
    Asciidoctor.load(text, attributes: ASCIIDOC_ATTRIBUTES).tap do |doc|
      doc.convert # Why do I need to do this?  No idea...
      doc.set_attribute('toc', 'macro')
      doc.set_attribute('toc-placement', 'macro')
    end
  end

  def self.replace_doc_with_macro(text)
    text.gsub(/^\s*:toc:.*$/, 'toc::[]')
  end

  def self.metadata_html(asciidoc_doc)
    attrs = asciidoc_doc.attributes

    %(<span id="metadata" author="#{attrs['author']}" version="#{attrs['neo4j-version']}" twitter="#{attrs['twitter']}" tags="#{attrs['tags']}" />)
  end

  #   let_context url: 'http://github.com/neo4j-examples/graphgists/blob/master/fraud/bank-fraud-detection.adoc' do
  #     it { should eq 'https://raw.githubusercontent.com/neo4j-examples/graphgists/master/fraud/bank-fraud-detection.adoc' }

  def self.url_regexp(url_host_and_path)
    %r{^(https?://)(?:[^:]+:[^@]+@)?#{url_host_and_path}$}
  end

  def self.raw_url_for(url) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
    case url.strip
    when url_regexp(%r{gist\.github\.com/([^/]+/)?([^/]+)/?(edit|[0-9a-f]{40})?/?})
      GitHub.url_from_gist_api($3, ($4.to_s.size == 40) ? $4 : nil)

    when url_regexp(%r{gist\.neo4j\.org/\?(.+)})
      raw_url_for_graphgist_id($2)

    when url_regexp(%r{graphgist.neo4j.com/#!/gists/([^/]+)/?})
      id = $2
      raw_url_for_graphgist_id(id) if id && !id.match(/[0-9a-f]{32}/)

    when url_regexp(%r{(www\.)?github\.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)/?})
      GitHub.raw_url_from_api($3, $4, $6, $5)

    when url_regexp(%r{(www\.)?dropbox\.com/s/([^/]+)/([^\?]+)(\?dl=(0|1))?})
      "https://www.dropbox.com/s/#{$3}/#{$4}?dl=1"

    when url_regexp(%r{docs.google.com/document/d/([^\/]+)(/edit)?})
      "https://docs.google.com/document/u/0/export?format=txt&id=#{$2}"

    when url_regexp(%r{([^/]*etherpad[^/]*/([^/]+/)*)p/([^/]+)/?})
      "#{$1}#{$2}p/#{$4}/export/txt"

    when url_regexp(%r{(www.)?pastebin.com/([^/]+)/?})
      "http://pastebin.com/raw.php?i=#{$3}"

    else
      url if url_returns_text_content_type?(url)
    end
  end

  class BasicAuthRequiredError < StandardError; end

  def self.url_returns_text_content_type?(url)
    http_connection = Faraday.new url: url
    result = http_connection.head url

    fail BasicAuthRequiredError if result.status == 401 && result['www-authenticate']

    [200, 302].include?(result.status) && result.headers['content-type'].match(%r{^text/})
  rescue URI::InvalidURIError, Faraday::ConnectionFailed
    nil
  end


  def self.raw_url_for_graphgist_id(graphgist_id)
    id = graphgist_id.nil? ? nil : URI.decode(graphgist_id) if graphgist_id

    raw_url = raw_url_for_provider(id)
    return raw_url if raw_url

    if id.match(%r{^(https?://[^/]+)/(.+)$})
      _, host, path = id.match(%r{^(https?://[^/]+)/(.+)$}).to_a
      host + '/' + URI.encode(URI.decode(path))
    else
      GitHub.url_from_gist_api(id)
    end
  end

  def self.raw_url_for_provider(id)
    case id
    when %r{^github-([^/]*)/([^/]*)/(.*)$}
      GitHub.raw_url_from_api($1, $2, $3)
    when /^dropbox(s?)-(.*)$/
      "https://dl.dropboxusercontent.com/#{$1.empty? ? 'u' : 's'}/#{$2}"
    when /^copy-(.*)$/
      "https://copy.com/#{$1}?download=1"
    end
  end


  module GitHub
    def self.api_headers
      ENV['GITHUB_TOKEN'] ? {'Authorization' => "token #{ENV['GITHUB_TOKEN']}"} : {}
    end

    def self.raw_url_from_api(owner, repo, path, branch = 'master')
      url = "https://api.github.com/repos/#{owner}/#{repo}/contents/#{path}?ref=#{branch}"
      data = JSON.load(open(url, api_headers).read)

      data['download_url']
    rescue OpenURI::HTTPError
      puts "WARNING: Error trying to fetch: #{url}"
      return nil
    end

    def self.url_from_gist_api(id, revision = nil)
      url = "https://api.github.com/gists/#{id}#{'/' + revision if revision}"
      data = JSON.load(open(url, api_headers).read)

      fail InvalidGraphGistIDError, 'Gist has more than one file!' if data['files'].size > 1

      data['files'].to_a[0][1]['raw_url']
    rescue OpenURI::HTTPError
      puts "WARNING: Error trying to fetch: #{url}"
      return nil
    end
  end
end
