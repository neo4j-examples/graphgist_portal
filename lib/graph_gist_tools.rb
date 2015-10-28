require 'json'
require 'open-uri'

module GraphGistTools
  ASCIIDOC_ATTRIBUTES = ['env-graphgist']

  COMMENT_REPLACEMENTS = {
    console: '<p class="console"><span class="loading"><i class="icon-cogs"></i> Running queries, preparing the console!</span></p>',

    graph_result: '<h5 class="graph-visualization" graph-mode="result"><i class="huge spinner loading icon"></i></h5>',
    graph: '<h5 class="graph-visualization">Loading graph...<i class="huge spinner loading icon"></i></h5>',
    table: '<h5 class="result-table">Loading table...<i class="huge spinner loading icon"></i></h5>',

    hide: '<span class="hide-query"></span>',
    setup: '<span class="setup"></span>',
    output: '<span class="query-output"></span>'
  }

  def self.asciidoc_document(asciidoc_text)
    text = asciidoc_text.dup
    COMMENT_REPLACEMENTS.each do |tag, replacement|
      text.gsub!(Regexp.new(%r{^//\s*#{tag}}, 'gm'), "++++\n#{replacement}\n++++\n")
    end

    Asciidoctor.load(text, attributes: ASCIIDOC_ATTRIBUTES)
  end

 #   let_context url: 'http://github.com/neo4j-examples/graphgists/blob/master/fraud/bank-fraud-detection.adoc' do
 #     it { should eq 'https://raw.githubusercontent.com/neo4j-examples/graphgists/master/fraud/bank-fraud-detection.adoc' }

  def self.raw_url_for(url)
    case url.strip
    when %r{^https?://gist\.github\.com/([^/]+/)?(.+)$}
      url_from_github_graphgist_api($2)
    when %r{^https?://gist\.neo4j\.org/\?(.+)$}
      raw_url_for_graphgist_id($1)
    when %r{^https?://(www\.)?github\.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)/?$}
      raw_url_from_github_api($2, $3, $5, $4)
    end
  end

  def self.raw_url_for_graphgist_id(graphgist_id)
    id = URI.decode(graphgist_id)
    case id
    when /^github-(.*)$/
      parts = $1.split('/')
      raw_url_from_github_api(parts[0], parts[1], parts[3..-1].join('/'))
    else
      url_from_github_graphgist_api(id)
    end
  end

  def self.raw_url_from_github_api(owner, repo, path, branch = 'master')
    begin
      url = "https://api.github.com/repos/#{owner}/#{repo}/contents/#{path}?ref=#{branch}"
      data = JSON.load(open(url).read)
    rescue OpenURI::HTTPError => e
      puts "WARNING: Error trying to fetch: #{url}"
      return nil
    end

    data['download_url']
  end

  def self.url_from_github_graphgist_api(id)
    begin
      url = "https://api.github.com/gists/#{id}"
      data = JSON.load(open(url).read)
    rescue OpenURI::HTTPError => e
      puts "WARNING: Error trying to fetch: #{url}"
      return nil
    end

    fail ArgumentError, "Gist has more than one file!" if data['files'].size > 1

    data['files'].to_a[0][1]['raw_url']
  end
end

