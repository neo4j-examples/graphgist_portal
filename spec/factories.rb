FactoryGirl.define do
  GIST_URLS = Rails.root.join('db', 'gist_urls.txt').read.split(/\n/)

  factory :graph_gist do
    sequence(:title) { |i| "GraphGist ##{i}" }
    featured false
    sequence(:url) { |i| GIST_URLS[i] }
  end
end
