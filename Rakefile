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

def verify_page_links(url)
  require 'nokogiri'

  uri = URI(url)

  response = Faraday.get(url)

  return [url] if response.status != 200

  doc = Nokogiri::HTML(response.body)

  gist_paths = doc.xpath('//a').map {|a| a.attributes['href'].value }.select do |href|
    yield href
  end

  failed_urls = []

  puts "Checking #{gist_paths.size} gist paths..."
  Parallel.each(gist_paths, in_threads: 8) do |path|
    link_url = url_from_path(path, uri)
    failed_urls << link_url if !url_working?(link_url)
  end

  failed_urls
end

task :spider_verify do
  require 'faraday'
  require 'parallel'

  host = 'http://portal.graphgist.org'

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
    puts "All paths check out!"
  else
    puts "The following paths returned non-200 statuses:"
    puts failed_urls
    exit(false)
  end
end

