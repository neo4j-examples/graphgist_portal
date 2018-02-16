def final_url(url, times_tried = 0)
  uri = uri_for_url(url)
  return if uri.nil?

  begin
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https'), ca_file: '/etc/openssl/cacert.pem') do |http|
      http.request(Net::HTTP::Head.new(uri.request_uri))
    end
  rescue SocketError, Errno::ECONNREFUSED
    return
  rescue Errno::ETIMEDOUT
    if times_tried > 2
      puts "WARNING: Failed to get URL #{url} after multiple attempts"
      return nil
    else
      return final_url(url, times_tried + 1)
    end
  end

  res['location'] ? final_url(res['location']) : url
end

def uri_for_url(url)
  return if url.nil?
  begin
    uri = URI.parse(url)
  rescue URI::InvalidURIError
    return
  end
  return if !uri.is_a?(URI::HTTP)

  uri
end

namespace :legacy_graph_gist_portal do
  task import_legacy_db: :environment do
    legacy_db = Neo4j::Session.open(:http, ENV['LEGACY_GRAPHGIST_DB_URL'])

    gists = legacy_db.query.match(gist: :Gist).pluck(:gist)

    puts 'Importing Gists'
    gists.each do |gist|
      props = gist.props
      updated_at = props[:updated] / 1000 if props[:updated].present?
      poster_image_url = final_url(props[:poster_image])
      url = final_url(props[:url])
      new_props = {
        legacy_neo_id: gist.neo_id,
        legacy_id: props[:id],
        legacy_poster_image: poster_image_url,
        summary: props[:summary],
        title: props[:title],
        status: props[:status],
        updated_at: updated_at,
        legacy_rated: props[:rated],
        private: false
      }
      graph_gist = GraphGist.find_or_create({legacy_neo_id: gist.neo_id}, new_props)

      begin
        if poster_image_url.present?
          image = GraphStarter::Image.create(source: open(poster_image_url), original_url: poster_image_url)
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
      begin
        graph_gist.place_url url
      rescue ArgumentError => e
        if e.message.match('Gist has more than one file!')
          next
        else
          raise e
        end
      end
      graph_gist.place_asciidoc(open(graph_gist.raw_url).read) if graph_gist.raw_url.present?
      graph_gist.save
      putc '.'
    end

    people = legacy_db.query.match(person: :Person).pluck(:person)
    puts 'Importing People'
    people.each do |person|
      props = person.props

      new_props = {
        name: props[:name],
        twitter_username: props[:twitter] && props[:twitter].downcase,
        created_at: props[:created] && props[:created] / 1000,
        updated_at: props[:updated] && props[:updated] / 1000,
        email: props[:email],
        postal_address: props[:postal_address],
        tshirt_size: props[:tshirt_size],
        tshirt_size_other: props[:tshirt_size_other]
      }.reject { |_, v| v.nil? }

      Person.find_or_create({legacy_neo_id: person.neo_id}, new_props)
      putc '.'
    end

    people_and_gists_neo_ids = legacy_db.query.match('(gist:Gist)<-[:WRITER_OF]-(person:Person)').pluck('ID(person)', 'ID(gist)')
    people_by_gists = people_and_gists_neo_ids.each_with_object({}) do |(person_neo_id, gist_neo_id), result|
      result[person_neo_id] ||= []
      result[person_neo_id] << gist_neo_id
    end

    puts
    puts

    people_by_gists.each do |person_neo_id, gist_ids|
      person = Person.find_by(legacy_neo_id: person_neo_id)
      gists = gist_ids.map { |id| GraphGist.find_by(legacy_neo_id: id) }.compact

      person.authored_gists = gists
      putc '.'
    end
  end
end
