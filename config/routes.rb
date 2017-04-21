Rails.application.routes.draw do
  # constraints(host: /graphgist-portal.herokuapp.com/) do
  #   match '/(*path)' => redirect { |params, _req| "http://portal.graphgist.org/#{params[:path]}" }, via: [:get, :post]
  # end

  mathjax 'mathjax'

  root 'info#featured_graphgists'
  get 'featured_graphgists(.:format)' => 'info#featured_graphgists'
  get 'about' => 'info#about'

  get 'submit_graphgist' => 'info#submit_graphgist'
  get 'submit_challenge_entry' => 'info#submit_challenge_entry'

  post 'preview_graphgist' => 'info#preview_graphgist'
  get 'preview_graphgist/:id' => 'info#preview_graphgist'
  patch 'preview_graphgist/:id' => 'info#preview_graphgist'

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

  match 'graph_gists/:id_or_slug/graph_guide' => 'info#graph_guide_options', via: :options
  get 'graph_gists/:id_or_slug/graph_guide' => 'info#graph_guide', as: :graph_guide
  get 'graph_gists/:id/edit_by_owner' => 'assets#edit_graph_gists_by_owner', as: :graph_edit_by_owner
  patch 'graph_gists/:id/edit_by_owner' => 'assets#update_graph_gists_by_owner', as: :graph_update_by_owner

  get 'graph_gists/:id/recommendations.json' => 'info#graphgist_recommendations'

  get 'live_graphgists(.:format)' => 'info#live_graphgists'
  get 'graph_gists/.json' => 'graph_starter/assets#show'

  get 'graph_gists/query_session_id' => 'query#graph_gist_query_session_id'
  post 'graph_gists/:graphgist_id/query' => 'query#graph_gist_query'

  get 'render_graphgist_js' => 'info#render_graphgist_js'

  devise_for :users, controllers: {registrations: 'users/registrations', omniauth_callbacks: 'users/omniauth_callbacks'}

  get ':model_slug/:id(.:format)' => 'assets#show', as: :asset
  mount GraphStarter::Engine, at: '/'
end
