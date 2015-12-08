Rails.application.routes.draw do
  mathjax 'mathjax'

  root 'info#featured_graphgists'
  get 'featured_graphgists(.:format)' => 'info#featured_graphgists'
  get 'about' => 'info#about'
  get 'challenge' => 'info#challenge'
  get 'submit_graphgist' => 'info#submit_graphgist'
  get 'preview_graphgist' => 'info#preview_graphgist'
  post 'create_graphgist' => 'info#create_graphgist'

  get 'render_graphgist' => 'info#render_graphgist'

  get 'show_from_graphgist_id/:id(.:format)' => 'info#show_from_graphgist_id'

  get 'graph_gists/:id/recommendations.json' => 'info#graphgist_recommendations'

  get 'render_graphgist_js' => 'info#render_graphgist_js'

  devise_for :users, controllers: {registrations: 'users/registrations', omniauth_callbacks: 'users/omniauth_callbacks'}

  mount GraphStarter::Engine, at: '/'
end
