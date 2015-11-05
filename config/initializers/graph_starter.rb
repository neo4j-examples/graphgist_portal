GraphStarter.configure do |config|
  config.menu_models = %i(GraphGist Industry UseCase)

  config.icon_classes = {
    GraphGist: 'file text icon',
    Person: 'user'
  }

  config.scope_filters = {
    GraphGist: -> (graph_gists) do
      graph_gists.where(status: 'live')
    end
  }

  config.editable_properties = {
    GraphGist: %w(title url featured status)
  }
end
