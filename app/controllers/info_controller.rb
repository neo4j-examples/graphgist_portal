class InfoController < ApplicationController
  def featured_graphgists
    @featured_graphgists = GraphGist.only_featured.to_a
    @featured_page = true
  end

  def about
  end

  def graphgist_recommendations
    graphgist = GraphGist.find(params[:id])

    @recommendations = graphgist.secret_sauce_recommendations
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

    return if !@graphgist.save

    @graphgist.update_attribute(:title, params[:title])

    redirect_to controller: 'graph_starter/assets', action: 'show', id: @graphgist.id, model_slug: 'graph_gists'
  end

  def render_graphgist
    url = GraphGistTools.raw_url_for_graphgist_id(params[:id])
    if url.present?
      @graphgist = GraphGist.new(url: url)
    end
  end

  def render_graphgist_js
    render layout: false
  end
end
