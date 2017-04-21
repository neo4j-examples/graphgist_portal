class InfoController < ApplicationController
  def featured_graphgists
    @title = 'Home'

    @featured_graphgists = apply_associations(GraphGist.only_featured).to_a
    @featured_page = true
  end

  def live_graphgists
    @live_graphgists = apply_associations(GraphGist.only_live.for_category('asset', params[:category])).to_a
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


  def challenge_graphgists
    @graph_gists = GraphGist.as(:gist).challenge_category.pluck(:gist)
  end

  def refresh_graphgist
    fail 'Must be an admin user' if !current_user.admin?

    graph_gist = GraphGist.find(params[:id])
    graph_gist.place_current_url
    graph_gist.save

    redirect_to graph_starter.asset_path(model_slug: :graph_gists, id: params[:id])
  end

  def about
    @title = 'What is a GraphGist?'
  end

  def graphgist_recommendations
    graphgist = GraphGist.find(params[:id])

    @recommendations = graphgist.secret_sauce_recommendations
  end

  def submit_graphgist
    @title = 'Submit a GraphGist'
  end

  def submit_challenge_entry
    @title = 'Submit a GraphGist'
  end

  def preview_graphgist
    id = params[:id]
    url = params[:graph_gist] ? params[:graph_gist][:url] : params[:url]
    asciidoc = params[:graph_gist] ? params[:graph_gist][:asciidoc] : params[:asciidoc]

    if id.present?
      @graphgist = GraphGist.find(id)
    else
      @graphgist = GraphGist.new(title: 'Preview')
    end

    if url.present?
      @graphgist.url = url
    elsif asciidoc.present?
      @graphgist.asciidoc = asciidoc
    end

    @graphgist.place_current_url

    @hide_menu = true

    @no_ui_container = true
  end

  def add_credentials_to_url(url, username, password)
    URI(url).tap do |uri|
      uri.user = CGI.escape username
      uri.password = CGI.escape password
    end.to_s
  end

  def show_from_url
    @graphgist = GraphGist.new(url: params[:url], title: 'Preview')

    @graphgist.place_current_url

    @warn_of_preview = true

    render 'preview_graphgist'
  rescue GraphGistTools::InvalidGraphGistIDError => e
    render text: e.message, status: :bad_request
  end

  def show_from_graphgist_id
    @asset = GraphGist.from_graphgist_id(params[:id])

    @asset.place_current_url if @asset

    if @asset && @asset.valid?
      @model_slug = 'graph_gists'
      render 'graph_starter/assets/show'
    else
      render text: "Invalid GraphGist ID (#{@asset && @asset.errors.messages.inspect})", status: :bad_request
    end
  rescue GraphGistTools::InvalidGraphGistIDError => e
    render text: e.message, status: :bad_request
  end

  skip_before_action :verify_authenticity_token, only: :graph_guide_options
  def graph_guide_options
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Headers'] = 'Pragma,Cache-Control,If-Modified-Since,Content-Type,X-Requested-With,X-stream,X-Ajax-Browser-Auth'
    response.headers['Access-Control-Allow-Methods'] = 'GET'

    render text: ''
  end

  def graph_guide
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Headers'] = 'Pragma,Cache-Control,If-Modified-Since,Content-Type,X-Requested-With,X-stream,X-Ajax-Browser-Auth'
    response.headers['Access-Control-Allow-Methods'] = 'GET'

    @graph_gist = GraphGist.as(:g).where('g.slug = {id_or_slug} OR g.uuid = {id_or_slug}', id_or_slug: params[:id_or_slug]).first

    render 'graph_guide', layout: false
  end

  def create_graphgist # rubocop: disable Metrics/AbcSize
    Neo4j::Transaction.run do
      if params[:graph_gist][:url].empty?
        params[:graph_gist].delete :url
      end

      @graphgist = GraphGist.create(params[:graph_gist].except(:industries, :use_cases, :challenge_category))

      # Grrr...
      industries, use_cases, challenge_category = params[:graph_gist].values_at(:industries, :use_cases, :challenge_category)
      @graphgist.industries = Industry.where(uuid: industries.uniq) unless industries.nil?
      @graphgist.use_cases = UseCase.where(uuid: use_cases.uniq) unless use_cases.nil?
      @graphgist.challenge_category = UseCase.find(challenge_category) unless challenge_category.nil?

      @graphgist.author = current_user.person
      @graphgist.creators << current_user

      # GraphGistMailer.thanks_for_submission(@graphgist, current_user).deliver_now
    end

    return render text: "Could not create GraphGist: #{@graphgist.errors.messages.inspect}" if @graphgist.errors.present?

    redirect_to graph_starter.asset_path(id: @graphgist.id, model_slug: 'graph_gists')
  end

  def render_graphgist
    url = GraphGistTools.raw_url_for_graphgist_id(params[:id])
    @graphgist = GraphGist.new(url: url) if url.present?
  end

  def render_graphgist_js
    render layout: false
  end

  # For externally testing that the app is up
  def monitor
    if GraphGist.first
      render text: 'OK', status: :ok
    else
      render text: 'SERVICE UNAVAILABLE', status: :service_unavailable
    end
  end
end
