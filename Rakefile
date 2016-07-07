# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

require 'faraday'
require 'nokogiri'

def url_working?(url, previous_tries = 0)
  return false if previous_tries == 2

  response = Faraday.head(url)

  (response && response.status == 200) || url_working?(url, previous_tries + 1)
end

def url_from_path(path, uri)
  if path.match(%r{^http://})
    path
  else
    File.join("#{uri.scheme}://#{uri.host}:#{uri.port}", path)
  end
end

def page_hrefs(url, &block)
  require 'nokogiri'

  response = Faraday.get(url)

  return [url] if response.status != 200

  Nokogiri::HTML(response.body).xpath('//a').map { |a| a.attributes['href'].value }.select(&block)
end

task :spider_verify, [:host] do |_t, args|
  args.with_defaults(host: 'http://portal.graphgist.org')

  require 'faraday'
  require 'parallel'

  host = args[:host]

  urls_to_verify = %w(/about /submit_graphgist /users/sign_in /featured_graphgists.json)

  gist_urls = []
  gist_urls += page_hrefs(host) { |href| href.match(%r{/graph_gists/[^/]+}) }
  gist_urls += page_hrefs(File.join(host, '/graph_gists')) { |href| href.match(%r{/graph_gists/[^/]+}) }
  gist_urls.uniq!

  urls_to_verify += gist_urls
  urls_to_verify += gist_urls.select { |url| url.count('/') > 2 }.map { |url| url + '.json' }

  # Preview page
  urls_to_verify << 'http://portal.graphgist.org/graph_gists/by_url?url=https%3A%2F%2Fgist.github.com%2Fcheerfulstoic%2F449393e2d1b6806112f1'

  urls_to_verify.map! { |string| url_from_path(string, URI(host)) }

  failed_urls = []
  semaphore = Mutex.new
  puts "Checking #{urls_to_verify.size} urls..."
  Parallel.each(urls_to_verify, in_threads: 3) do |url_to_verify|
    semaphore.synchronize { puts "Checking #{url_to_verify}" }

    failed_urls << url_to_verify if !url_working?(url_to_verify)
  end

  if failed_urls.empty?
    puts 'All paths check out!'
  else
    puts 'The following paths returned non-200 statuses:'
    puts failed_urls
    exit(false)
  end
end
