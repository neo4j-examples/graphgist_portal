GraphStarter.configure do |config|
  #  config.menu_models = %i(GraphGist Industry UseCase)
  config.menu_models = %i()

  config.icon_classes = {
    GraphGist: 'file text icon',
    Person: 'user'
  }

  config.scope_filters = {
    GraphGist: -> (var) do
      "#{var}.status = 'live'"
    end
  }

  config.editable_properties = {
    GraphGist: %w(title url featured status)
  }

  config.default_image_style = :medium
end
