class InfoController < ApplicationController
  def featured_graphgists
    @featured_graphgists = GraphGist.only_featured.to_a
  end

  def about
  end

  def submit_graphgist
  end

  def preview_graphgist
    @graphgist = GraphGist.new(url: params[:url])

    @graphgist.place_updated_url

    @hide_menu = true
  end

  def create_graphgist
    @graphgist = GraphGist.new(url: params[:url], status: 'candidate')
    @graphgist.save
    @graphgist.update_attribute(:title, params[:title])

    redirect_to controller: 'graph_starter/assets', action: 'show', id: @graphgist.id
  end
end
