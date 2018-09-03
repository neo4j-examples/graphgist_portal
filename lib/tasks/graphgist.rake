namespace :graphgist do
  desc "Check for invalid URLs"
  task check_invalid_urls: :environment do
    GraphGist.find_each do |g|
      g.check_for_broken_links
      if g.errors.present?
        puts "GraphGist: #{g.id} => #{g.errors.messages.inspect}\n"
      end
    end
  end

  desc "Populate neo4j_version field"
  task populate_neo4j_version: :environment do
    GraphGist.find_each do |g|
      if !g.neo4j_version.present?
        g.place_neo4j_version
        g.save
        puts "GraphGist: #{g.id} => #{g.neo4j_version}\n"
      end
    end
  end
end
