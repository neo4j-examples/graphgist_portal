json.array! @assets do |asset|
  json.merge! asset.as_json

  json.created_at asset.created_at
  json.updated_at asset.updated_at

  if asset.is_a?(GraphGist)
    json.featured asset.featured
  end

  if asset.is_a?(Industry) || asset.is_a?(UseCase)
    json.num_graphgists asset.num_graphgists
  end
end