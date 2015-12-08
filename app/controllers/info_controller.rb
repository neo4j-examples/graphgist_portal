class InfoController < ApplicationController
  def featured_graphgists
    @featured_graphgists = apply_associations(GraphGist.only_featured).to_a
    @featured_page = true
  end


  def associations
    return @associations if @associations.present?

    @associations = []
    @associations << GraphGist.image_association
    @associations += GraphGist.category_associations
    @associations.compact!
    @associations
  end

  def apply_associations(scope, var = :asset)
    if associations.present?
      # Gah, shouldn't need this proxy_as business.  Bug to fix, I think...
      scope.query_as(var).with(var).proxy_as(GraphGist, var).with_associations(*associations)
    else
      scope
    end
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

  def show_from_graphgist_id
    @asset = GraphGist.new(url: GraphGistTools.raw_url_for_graphgist_id(params[:id]))

    @asset.place_updated_url

    render 'graph_starter/assets/show'
  end

  def create_graphgist
    @graphgist = GraphGist.new(url: params[:url], status: 'candidate')

    return if !@graphgist.save

    @graphgist.update_attribute(:title, params[:title])

    redirect_to controller: 'graph_starter/assets', action: 'show', id: @graphgist.id, model_slug: 'graph_gists'
  end

  def render_graphgist
    url = GraphGistTools.raw_url_for_graphgist_id(params[:id])
    @graphgist = GraphGist.new(url: url) if url.present?
  end

  def render_graphgist_js
    render layout: false
  end
end
