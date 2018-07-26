json.array! @featured_graphgists do |asset|
  json.merge! asset.as_json

  json.created_at asset.created_at
  json.updated_at asset.updated_at
  json.featured asset.featured
end
