
require 'net/http'
require 'uri'

if ENV['DISABLE_SSL_VERIFY_PEER_THIS_IS_A_BAD_IDEA_TOO_HAVE_ON_ALL_THE_TIME']
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end

namespace :graph_gist_portal do
  task refresh_graphgist_html: :environment do
    GraphGist.all.each do |graphgist|
      graphgist.place_asciidoc(graphgist.asciidoc) if graphgist.asciidoc
      graphgist.save
    end
  end

  task refresh_graphgist_query_cache: :environment do
    GraphGist.all.each do |graphgist|
      graphgist.place_query_cache if graphgist.asciidoc
      graphgist.save
    end
  end

  task import_twitter_profile_images: :environment do
    client = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token    = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end

    Person.where_not(twitter_username: nil).each do |person|
      puts "Getting icon for #{person.twitter_username}..."
      begin
        url = client.user(person.twitter_username.delete('@')).profile_image_url.to_s.gsub(/_(normal|bigger|mini)\./, '.')
      rescue Twitter::Error::NotFound, Twitter::Error::Forbidden
        next
      end

      puts "Got profile image URL: #{url}"

      image = GraphStarter::Image.create(source: open(url), original_url: url)
      person.image = image
      person.save
    end
  end

  def get_github_url(url)
    JSON.load(open(url + "?token=#{ENV['GITHUB_TOKEN']}").read)
  end

  task import_featured_graphgists: :environment do
    base_url = 'https://api.github.com/repos/neo4j-examples/graphgists/contents'

    get_github_url(base_url).each do |base_file|
      next if base_file['type'] != 'dir'

      dir_name = base_file['name']
      get_github_url("#{base_url}/#{dir_name}").each do |file|
        next if !file['name'].match(/\.adoc$/)

        url = "https://github.com/neo4j-examples/graphgists/blob/master/#{dir_name}/#{file['name']}"

        graph_gist = GraphGist.new(url: url, status: 'live', private: false, featured: true)

        raw_url = GraphGistTools.raw_url_for(url)
        doc = Asciidoctor.load(open(raw_url).read)
        html_doc = Nokogiri::HTML(doc.convert)

        first_image_url = html_doc.search('img').map do |img|
          img.attributes['src'].value
        end.detect do |image_url|
          open(image_url).read
        end

        begin
          if first_image_url.present?
            image = GraphStarter::Image.create(source: open(first_image_url), original_url: first_image_url)
            if graph_gist.class.has_images?
              graph_gist.images << image
            elsif graph_gist.class.has_image?
              graph_gist.image = image
            end
          end
        rescue OpenURI::HTTPError => http_error
          allowed_errors = ['403 Forbidden', '404 Not Found']
          raise http_error unless allowed_errors.include?(http_error.message)
        end
        graph_gist.place_asciidoc(open(graph_gist.raw_url).read) if graph_gist.raw_url.present?
        graph_gist.save
        puts 'graph_gist.id', graph_gist.id
      end
    end
  end
end
