Rails.application.routes.draw do
  mathjax 'mathjax'

  root 'info#featured_graphgists'
  get 'about' => 'info#about'
  get 'submit' => 'info#submit'

  devise_for :users, :controllers => { :registrations => "users/registrations" }

  mount GraphStarter::Engine, at: '/'
end
