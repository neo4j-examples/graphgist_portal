FactoryGirl.define do
  factory :graph_gist do
    sequence(:title) { |i| "GraphGist ##{i}" }
    featured false
    status 'live'
    asciidoc File.read("./spec/features/acid_test.adoc")
  end
end
