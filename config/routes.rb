Rails.application.routes.draw do
  # constraints(host: /graphgist-portal.herokuapp.com/) do
  #   match '/(*path)' => redirect { |params, _req| "http://portal.graphgist.org/#{params[:path]}" }, via: [:get, :post]
  # end

  mathjax 'mathjax'

  root 'info#home'
  get 'about' => 'info#about'

  get 'featured_graphgists(.:format)' => 'info#featured_graphgists'

  get 'submit_graphgist' => 'info#submit_graphgist'

  get 'submit_challenge_entry' => 'info#submit_challenge_entry'

  post 'preview_graphgist' => 'info#preview_graphgist'
  get 'preview_graphgist/:id' => 'info#preview_graphgist'
  patch 'preview_graphgist/:id' => 'info#preview_graphgist'

  get 'monitor' => 'info#monitor'

  authenticated do
    post 'create_graphgist' => 'info#create_graphgist'
    get 'my_graphgists' => 'info#my_graphgists'
  end

  get 'challenge_graphgists' => 'info#challenge_graphgists'

  get 'render_graphgist' => 'info#render_graphgist'

  get 'graph_gists/by_graphgist_id/*id(.:format)' => 'info#show_from_graphgist_id'
  get 'graph_gists/by_graphgist_id(.:format)' => 'info#show_from_graphgist_id'
  get 'graph_gists/by_url' => 'info#show_from_url'
  get 'graph_gists/new' => redirect('submit_graphgist')
  # Deprecated:
  get 'show_from_graphgist_id/:id(.:format)' => 'info#show_from_graphgist_id'

  match 'graph_gists/:id_or_slug/graph_guide' => 'info#graph_guide_options', via: :options
  get 'graph_gists/:id_or_slug/graph_guide' => 'info#graph_guide', as: :graph_guide

  get 'graph_gists/:id/edit_by_owner' => 'assets#edit_graph_gists_by_owner', as: :graph_edit_by_owner
  patch 'graph_gists/:id/edit_by_owner' => 'assets#update_graph_gists_by_owner', as: :graph_update_by_owner

  get 'graph_gists/:id/edit_by_owner_step2' => 'assets#edit_graph_gists_by_owner_step2', as: :graph_edit_by_owner_step2
  patch 'graph_gists/:id/edit_by_owner_step2' => 'assets#update_graph_gists_by_owner_step2', as: :graph_update_by_owner_step2

  get 'graph_gists/:id/source' => 'assets#show_source', as: :graph_show_source

  get 'candidates/waiting_review' => 'info#list_candidates', as: :list_candidates_graphgist
  post 'candidates/graphgist/:id/status/live' => 'assets#make_graphgist_live', as: :make_graphgist_live
  post 'candidates/graphgist/:id/status/disabled' => 'assets#make_graphgist_disabled', as: :make_graphgist_disabled
  post 'candidates/graphgist/:id/status/candidate' => 'assets#make_graphgist_candidate', as: :make_graphgist_candidate

  get 'graph_gists/:id/recommendations.json' => 'info#graphgist_recommendations'

  get 'live_graphgists(.:format)' => 'info#live_graphgists'
  get 'graph_gists/.json' => 'graph_starter/assets#show'

  get 'graph_gists/query_session_id' => 'query#graph_gist_query_session_id'
  post 'graph_gists/:graphgist_id/query' => 'query#graph_gist_query'

  get 'render_graphgist_js' => 'info#render_graphgist_js'

  devise_for :users, controllers: {sessions: 'users/sessions', registrations: 'users/registrations', omniauth_callbacks: 'users/omniauth_callbacks'}

  get 'challenges/new' => 'assets#challenge_new'
  post 'challenges' => 'assets#challenge_create', as: :challenge_create

  get 'categories/:slug(.:format)' => 'categories#show'
  get 'models/:name' => 'models#show', as: :model
  get 'authorizables/user_and_group_search.json' => 'authorizables#user_and_group_search'
  get ':model_slug/new' => 'assets#new', as: :new_asset
  get ':model_slug' => 'assets#index', as: :assets
  post ':model_slug' => 'assets#create', as: :create_asset
  get ':model_slug/:id(.:format)' => 'assets#show', as: :asset
  get ':model_slug/:id/edit' => 'assets#edit', as: :edit
  patch ':model_slug/:id' => 'assets#update'
  get ':model_slug/search_by_title_category_and_author/:query.json' => 'assets#search_by_title_category_and_author', as: :search_by_title_category_and_author
  mount GraphStarter::Engine, at: '/'
end
