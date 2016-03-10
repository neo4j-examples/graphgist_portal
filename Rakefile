# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

require 'faraday'
require 'nokogiri'

def url_working?(url)
  puts "Checking #{url}"

  response = Faraday.head(url)

  response && response.status == 200
end

def url_from_path(path, uri)
  if path.match(%r{^http://})
    path
  else
    File.join("#{uri.scheme}://#{uri.host}:#{uri.port}", path)
  end
end

def hrefs_from_text(text, &block)
  Nokogiri::HTML(text).xpath('//a').map { |a| a.attributes['href'].value }.select(&block)
end

def verify_page_links(url, &block)
  require 'nokogiri'

  response = Faraday.get(url)

  return [url] if response.status != 200

  link_urls = hrefs_from_text(response.body, &block).map { |path| url_from_path(path, URI(url)) }

  failed_urls = []

  puts "Checking #{link_urls.size} gist paths..."
  Parallel.each(link_urls, in_threads: 8) do |link_url|
    failed_urls << link_url if !url_working?(link_url)
  end

  failed_urls
end

task :spider_verify, [:host] do |_t, args|
  args.with_defaults(host: 'http://portal.graphgist.org')

  require 'faraday'
  require 'parallel'

  host = args[:host]

  failed_urls = []

  failed_urls += verify_page_links(host) do |href|
    href.match(%r{/graph_gists/[^/]+})
  end

  failed_urls += verify_page_links(File.join(host, '/graph_gists')) do |href|
    href.match(%r{/graph_gists/[^/]+})
  end

  %w(/about /submit_graphgist /users/sign_in).each do |path|
    url = File.join(host, path)

    failed_urls << url if !url_working?(url)
  end

  if failed_urls.empty?
    puts 'All paths check out!'
  else
    puts 'The following paths returned non-200 statuses:'
    puts failed_urls
    exit(false)
  end
end
