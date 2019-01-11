class InfoController < ApplicationController
  before_action :authenticate_user!, :only => [:submit_graphgist, :my_graphgists, :create_graphgist]

  def featured_graphgists
    @title = 'Featured GraphGists'

    @featured_graphgists = apply_associations(GraphGist.only_featured.limit(30)).to_a

    @featured_page = true
  end

  def index_json
    params.permit!
    assets = GraphGist
      .query_as(:asset)
      .where('asset.status = "live"')

    if params[:category].present?
      assets = assets
        .match('(asset)-[:FOR_INDUSTRY|:FOR_USE_CASE]->(category)')
        .where('category.slug = {slug}')
        .params(slug: params[:category])
    end

    if params[:author].present?
      assets = assets
        .match('(asset)<-[:WROTE]-(author:Person)')
        .where('author.slug = {slug} OR author.uuid = {slug}')
        .params(slug: params[:author])
    end

    list_json(assets)
  end

  def featured_graphgists_json
    assets = GraphGist
      .query_as(:asset)
      .where("asset.featured = true")

    list_json(assets)
  end

  def list_json(assets)
    assets = assets
      .with('asset')
      .limit(30)
      .optional_match('(asset)-[:HAS_IMAGE]->(image:Image)')
      .with('asset, image')
      .optional_match('(asset)<-[:WROTE]-(author:Person)')
      .with('asset, image, author')
      .optional_match('(asset)-[:FOR_INDUSTRY]->(industry:Industry)')
      .with('asset, image, author, industry')
      .optional_match('(industry)-[:HAS_IMAGE]->(industry_image)')
      .with('asset, image, author, industry, head(collect(industry_image)) AS industry_image')
      .optional_match('(asset)-[:FOR_USE_CASE]->(use_case:UseCase)')
      .with('asset, image, author, industry, industry_image, use_case')
      .optional_match('(use_case)-[:HAS_IMAGE]->(use_case_image)')
      .with('asset, image, author, industry, industry_image, use_case, head(collect(use_case_image)) AS use_case_image')
      .pluck('asset {'\
        '.title,'\
        '.uuid,'\
        '.slug,'\
        '.summary,'\
        '.updated_at,'\
        '.featured,'\
        '.created_at,'\
        '.neo4j_version,'\
        'author: author {.uuid, .name, .slug},'\
        'image: head(collect(image)),'\
        'industries: collect(distinct industry {.uuid, .name, .slug, image: industry_image}),'\
        'use_cases: collect(distinct use_case {.uuid, .name, .slug, image: use_case_image})'\
      '}')

    assets_result = assets.map do |asset|
      author = asset[:author]
      first_image = asset[:image] ? asset[:image].source_url : nil

      {
        title: asset[:title],
        name: asset[:title],
        summary: asset[:summary],
        neo4j_version: asset[:neo4j_version],
        id: asset[:uuid],
        slug: asset[:slug],
        model_slug: params[:model_slug],
        updated_at: asset[:updated_at],
        created_at: asset[:created_at],
        featured: asset[:featured],
        image: first_image,
        author: author ? {
          model_slug: 'people',
          name: author[:name],
          title: author[:name],
          id: author[:uuid],
        } : nil,
        industries: asset[:industries].map do |category|
          category_first_image = category[:image] ? category[:image].source_url : nil

          {
            title: category[:name],
            name: category[:name],
            id: category[:uuid],
            slug: category[:slug],
            model_slug: 'industries',
            image: category_first_image
          }
        end,
        use_cases: asset[:use_cases].map do |category|
          category_first_image = category[:image] ? category[:image].source_url : nil

          {
            title: category[:name],
            name: category[:name],
            id: category[:uuid],
            slug: category[:slug],
            model_slug: 'use_cases',
            image: category_first_image
          }
        end
      }
    end

    render json: assets_result.to_json
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

  def home
    @title = 'Home'
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
    @graphgist_template = File.read('config/graphgist_template.adoc')
  end

  def submit_challenge_entry
    @title = 'Submit a GraphGist'
  end

  def preview_graphgist
    params.permit!
    id = params[:id]

    if params[:graph_gist_candidate]
      url = params[:graph_gist_candidate][:url]
      asciidoc = params[:graph_gist_candidate][:asciidoc]
    elsif params[:graph_gist]
      url = params[:graph_gist][:url]
      asciidoc = params[:graph_gist][:asciidoc]
    end

    if id.present?
      @graphgist = GraphGistCandidate.find(id)
    else
      @graphgist = GraphGistCandidate.new(title: 'Preview')
    end

    if url.present?
      @graphgist.url = url
      @graphgist.place_current_url
    elsif asciidoc.present?
      @graphgist.asciidoc = asciidoc
      @graphgist.place_current_asciidoc
    end

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
    redirect_to '/' if !current_user.present?

    Neo4j::ActiveBase.run_transaction do
      params.permit!

      if params[:graph_gist][:url].empty?
        params[:graph_gist].delete :url
      end

      @graphgist = GraphGist.create(params[:graph_gist].except(:industries, :use_cases, :challenge_category).merge({
        author: current_user.person,
        creators: [current_user]
      }))

      unless @graphgist.errors.present?
        @candidate = GraphGistCandidate.create_from_graphgist(@graphgist)
      end
    end

    if @graphgist.errors.present?
      flash[:error] = @graphgist.errors.messages.to_a.map {|pair| pair.join(' ') }.join(' / ')
      return redirect_to :back
    end

    redirect_to graph_edit_by_owner_step2_path(id: @graphgist.id)
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

  def list_candidates
    redirect_to '/' if !current_user.present? || !current_user.admin?

    @candidates = GraphGistCandidate.where(status: 'candidate')
  end

  def my_graphgists
    redirect_to '/' if !current_user.present?

    @title = 'My GraphGists'
    @graphgists = GraphGistCandidate.where(author: current_user.person)
  end
end
