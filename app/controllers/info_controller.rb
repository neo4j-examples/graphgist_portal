class InfoController < ApplicationController
  def featured_graphgists
    @title = 'Home'

    @featured_graphgists = apply_associations(GraphGist.only_featured).to_a
    @featured_page = true
  end

  def live_graphgists
    scope = GraphGist.only_live
    scope = scope.for_category(scope, params[:category]) if params[:category].present?

    @live_graphgists = apply_associations(scope).to_a
  end

  CONSOLE_HOSTS = {
    '1.9' => 'neo4j-console-19.herokuapp.com',
    '2.0' => 'neo4j-console-20.herokuapp.com',
    '2.1' => 'neo4j-console-21.herokuapp.com',
    '2.2' => 'neo4j-console-22.herokuapp.com',
    '2.3' => 'neo4j-console-23.herokuapp.com'
  }

  def graph_gist_query_session_id
    session_id = SecureRandom.uuid
    last_cache_keys[session_id] = nil

    render text: session_id
  end

  # gist_load_session given when loading gist?
  # GET /graph_gists/:graphgist_id/query?gist_load_session=something&neo4j_version=2.3&cypher=string
  def graph_gist_query
    cache_key = "#{last_cache_key}#{params[:graphgist_id]}#{Base64.encode64(params[:cypher])}"

    result = Rails.cache.fetch(cache_key) do
      fetch_query(*params.values_at(:cypher, :neo4j_version, :gist_load_session))
    end

    last_cache_keys[params[:gist_load_session]] = cache_key

    render text: result
  end

  def fetch_query(cypher, neo4j_version, gist_load_session)
    host = CONSOLE_HOSTS[neo4j_version] || CONSOLE_HOSTS[CONSOLE_HOSTS.keys.sort_by(&:to_f).last]

    type = last_cache_key ? 'cypher' : 'init'
    Faraday.post("http://#{host}/console/#{type}", cypher, 'X-Session': gist_load_session).body
  end

  def last_cache_key
    last_cache_keys.fetch(params[:gist_load_session])
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
    url = params[:graph_gist] ? params[:graph_gist][:url] : params[:url]

    authenticate_with_http_basic do |username, password|
      url = add_credentials_to_url(url, username, password)
    end

    @graphgist = GraphGist.new(url: url, title: 'Preview')

    @graphgist.place_current_url

    @hide_menu = true

    @no_ui_container = true
  rescue GraphGistTools::BasicAuthRequiredError
    request_http_basic_authentication(Base64.encode64(url).chomp)
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
    raw_url = GraphGistTools.raw_url_for_graphgist_id(params[:id])
    if raw_url
      @asset = GraphGist.new(url: raw_url, title: 'Preview')

      @asset.place_current_url
    end

    if raw_url && @asset.valid?
      @model_slug = 'graph_gists'
      render 'graph_starter/assets/show'
    else
      render text: "Invalid GraphGist ID (#{@asset && @asset.errors.messages.inspect})", status: :bad_request
    end
  rescue GraphGistTools::InvalidGraphGistIDError => e
    render text: e.message, status: :bad_request
  end

  def create_graphgist # rubocop: disable Metrics/AbcSize
    Neo4j::Transaction.run do
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


  private

  def last_cache_keys
    session[:last_cache_keys] ||= {}
  end
end
