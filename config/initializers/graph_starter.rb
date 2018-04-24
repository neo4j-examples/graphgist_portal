GraphStarter.configure do |config|
  #  config.menu_models = %i(GraphGist Industry UseCase)
  config.menu_models = %i()

  config.icon_classes = {
    GraphGist: 'file text icon',
    GraphGistCandidate: 'file text icon',
    Person: 'user'
  }

  config.scope_filters = {
    GraphGist: -> (var) do
      "#{var}.status = 'live'"
    end,
    GraphGistCandidate: -> (var) do
      "#{var}.status = 'candidate'"
    end
  }

  config.editable_properties = {
    GraphGist: %w(title featured status),
    GraphGistCandidate: %w(title)
  }

  config.default_image_style = :medium
end
