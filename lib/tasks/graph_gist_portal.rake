
require 'net/http'
require 'uri'


namespace :graph_gist_portal do

  def final_url(url)
    return if url.nil?
    begin
      uri = URI.parse(url)
    rescue URI::InvalidURIError
      return
    end
    return if !uri.is_a?(URI::HTTP)

    begin
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https'), ca_file: '/etc/openssl/cacert.pem') do |http|
        http.request(Net::HTTP::Head.new(uri.request_uri))
      end
    rescue SocketError
      return
    end

    res['location'] ? final_url(res['location']) : url
  end

  task import_legacy_db: :environment do
    legacy_db = Neo4j::Session.open(:server_db, ENV['LEGACY_GRAPHGIST_DB_URL']) 

    gists = legacy_db.query.match(gist: :Gist).pluck(:gist)

    puts 'Importing Gists'
    gists.each do |gist|
      props = gist.props
      updated_at = props[:updated] / 1000 if props[:updated].present?
      poster_image_url = final_url(props[:poster_image])
      url = final_url(props[:url])
      new_props = {
        legacy_neo_id: gist.neo_id,
        legacy_poster_image: poster_image_url,
        summary: props[:summary],
        title: props[:title],
        status: props[:status],
        updated_at: updated_at,
        legacy_rated: props[:rated],
        private: false
      }
      graph_gist = GraphGist.find_or_create({legacy_id: props[:id]}, new_props)

      begin
        graph_gist.images << GraphStarter::Image.create(source: open(poster_image_url), original_url: poster_image_url) if poster_image_url.present?
      rescue OpenURI::HTTPError => http_error
        allowed_errors = ['403 Forbidden', '404 Not Found']
        fail http_error unless allowed_errors.include?(http_error.message)
      end
      graph_gist.url = url
      graph_gist.place_asciidoc(open(graph_gist.raw_url).read) if graph_gist.raw_url.present?
      graph_gist.save
      putc '.'
    end

    people = legacy_db.query.match(person: :Person).pluck(:person)
    puts 'Importing People'
    people.each do |person|
      props = gist.props

      new_props = {
        name: props[:name],
        twitter_username: props[:twitter],
        created_at: props[:created] / 1000,
        updated_at: props[:updated] / 1000,
        email: props[:email],
        postal_address: props[:postal_address],
        tshirt_size: props[:tshirt_size],
        tshirt_size_other: props[:tshirt_size_other]
      }

      Person.find_or_create({legacy_neo_id: person.neo_id}, new_props)
      putc '.'
    end

    people_and_gists = legacy_db.query.match("(gist:Gist)<-[:WRITER_OF]-(person:Person)").pluck(:person, :gist)
    people_by_gists = people_and_gists.each_with_object({}) do |(person, gist), result|
      result[person.neo_id] ||= []
      result[person.neo_id] << gist.props[:id]
    end

    people_by_gists.each do |person_neo_id, gist_ids|
      person = Person.find(legacy_neo_id: person_neo_id)
      gists = gist_ids.map {|id| GraphGist.find(legacy_id: id) }

      gist.creators = gists
    end
 
  end
end

