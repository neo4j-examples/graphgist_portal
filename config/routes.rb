Rails.application.routes.draw do
  mathjax 'mathjax'

  root 'info#featured_graphgists'
  get 'featured_graphgists(.:format)' => 'info#featured_graphgists'
  get 'about' => 'info#about'
  get 'submit_graphgist' => 'info#submit_graphgist'
  get 'preview_graphgist' => 'info#preview_graphgist'
  post 'create_graphgist' => 'info#create_graphgist'

  get 'graph_gists/:id/recommendations.json' => 'info#graphgist_recommendations'

  get 'render_graphgist_js' => 'info#render_graphgist_js'

  devise_for :users, controllers: {registrations: 'users/registrations'}

  mount GraphStarter::Engine, at: '/'
end
