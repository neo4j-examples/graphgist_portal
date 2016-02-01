Rails.application.routes.draw do
  constraints(host: /graphgist-portal.herokuapp.com/) do
    match '/(*path)' => redirect { |params, _req| "http://portal.graphgist.org/#{params[:path]}" }, via: [:get, :post]
  end

  mathjax 'mathjax'

  root 'info#featured_graphgists'
  get 'featured_graphgists(.:format)' => 'info#featured_graphgists'
  get 'about' => 'info#about'

  get 'submit_graphgist' => 'info#submit_graphgist'
  get 'submit_challenge_entry' => 'info#submit_challenge_entry'

  get 'preview_graphgist' => 'info#preview_graphgist'

  get 'refresh_graphgist' => 'info#refresh_graphgist'

  get 'monitor' => 'info#monitor'

  authenticated do
    post 'create_graphgist' => 'info#create_graphgist'
  end

  get 'challenge_graphgists' => 'info#challenge_graphgists'

  get 'render_graphgist' => 'info#render_graphgist'

  get 'graph_gists/by_graphgist_id/*id(.:format)' => 'info#show_from_graphgist_id'
  get 'graph_gists/by_graphgist_id(.:format)' => 'info#show_from_graphgist_id'
  get 'graph_gists/by_url' => 'info#show_from_url'
  # Deprecated:
  get 'show_from_graphgist_id/:id(.:format)' => 'info#show_from_graphgist_id'

  get 'graph_gists/:id/recommendations.json' => 'info#graphgist_recommendations'

  get 'graph_gists/.json' => 'graph_starter/assets#show'

  get 'render_graphgist_js' => 'info#render_graphgist_js'

  devise_for :users, controllers: {registrations: 'users/registrations', omniauth_callbacks: 'users/omniauth_callbacks'}

  mount GraphStarter::Engine, at: '/'
end
