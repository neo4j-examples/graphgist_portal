namespace :graphgistcandidate do
  desc "Check for invalid URLs"
  task check_invalid_urls: :environment do
    GraphGistCandidate.find_each do |g|
      g.check_for_broken_links
      if g.errors.present?
        puts "GraphGistCandidate: #{g.id} => #{g.errors.messages.inspect}\n"
      end
    end
  end
end
