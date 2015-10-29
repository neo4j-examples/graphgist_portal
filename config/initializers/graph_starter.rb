GraphStarter.configure do |config|
  config.menu_models = %i(GraphGist)

  config.icon_classes = {
    GraphGist: 'file text icon',
    Person: 'user'
  }
end
