class AssetsController < ::GraphStarter::AssetsController

  def index
    super
    @assets.sort! { |a, b| [b.avg_rating, a.title] <=> [a.avg_rating, b.title] } if @assets.all? &.is_a?(GraphGist)
  end

  def search
    params.permit!

    query_string = params[:query]
    params[:model_slug] = "graph_gists"

    assets_ids = []
    assets_query = Neo4j::ActiveBase.current_session.query(
      "MATCH (asset:GraphGist {status:'live'}) "\
      "WHERE asset.title =~ {query} "\
      "RETURN asset.uuid AS id "\
      "LIMIT 30 "\
      "UNION "\
      "MATCH (asset:GraphGist)-[:FOR_INDUSTRY|:FOR_USE_CASE]->(category) "\
      "WHERE category.name =~ {query} "\
      "RETURN asset.uuid AS id "\
      "LIMIT 30 "\
      "UNION "\
      "MATCH (asset:GraphGist)<-[:WROTE]-(author:Person) "\
      "WHERE author.name =~ {query} "\
      "RETURN asset.uuid AS id "\
      "LIMIT 30",
    query: "(?i).*#{query_string}.*")

    assets_query.each do |asset|
      assets_ids.push(asset.id)
    end

    assets = GraphGist
      .query_as(:asset)
      .where("asset.uuid IN {ids}")
      .params(ids: assets_ids)
      .with(:asset)
      .optional_match('(asset)-[:HAS_IMAGE]->(image)')
      .pluck('asset {.title, .uuid, image: head(collect(image))}')

    results_data = assets.map do |asset|
      description = model_class.search_properties.map do |property|
        "<b>#{property.to_s.humanize}:</b> #{asset[property]}"
      end.join("<br>")

      first_image = asset[:image] ? asset[:image].source_url : nil

      {
        title: asset[:title],
        url: asset_path(id: asset[:uuid], model_slug: model_class.model_slug),
        description: description,
        image: first_image
      }.reject {|_, v| v.nil? }.tap do |result|
        model_class.search_properties.each do |property|
          result[property] = asset[property]
        end
      end
    end

    render json: {results: results_data}.to_json
  end

  def search_by_title_category_and_author
    params.permit!
    query_string = params[:query]
    params[:model_slug] = "graph_gists"

    assets_ids = []
    assets_query = Neo4j::ActiveBase.current_session.query(
      "MATCH (asset:GraphGist) "\
      "WHERE asset.title =~ {query} "\
      "RETURN asset.uuid AS id "\
      "LIMIT 30 "\
      "UNION "\
      "MATCH (asset:GraphGist)-[:FOR_INDUSTRY|:FOR_USE_CASE]->(category) "\
      "WHERE category.name =~ {query} "\
      "RETURN asset.uuid AS id "\
      "LIMIT 30 "\
      "UNION "\
      "MATCH (asset:GraphGist)<-[:WROTE]-(author:Person) "\
      "WHERE author.name =~ {query} "\
      "RETURN asset.uuid AS id "\
      "LIMIT 30",
    query: "(?i).*#{query_string}.*")

    assets_query.each do |asset|
      assets_ids.push(asset.id)
    end

    assets = GraphGist
      .query_as(:asset)
      .where("asset.uuid IN {ids}")
      .params(ids: assets_ids)
      .with('asset')
      .optional_match('(asset)-[:HAS_IMAGE]->(image)')
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
        '.updated_at,'\
        '.featured,'\
        '.created_at,'\
        'author: author {.uuid, .name, .slug},'\
        'image: head(collect(image)),'\
        'industries: collect(industry {.uuid, .name, .slug, image: industry_image}),'\
        'use_cases: collect(use_case {.uuid, .name, .slug, image: use_case_image})'\
      '}')

    results_data = assets.map do |asset|
      first_image = asset[:image] ? asset[:image].source_url : nil

      {
        title: asset[:title],
        name: asset[:title],
        id: asset[:uuid],
        slug: asset[:slug],
        model_slug: params[:model_slug],
        updated_at: asset[:updated_at],
        created_at: asset[:created_at],
        featured: asset[:featured],
        image: first_image,
        author: asset[:author] ? {
          model_slug: 'people',
          name: asset[:author][:name],
          title: asset[:author][:name],
          id: asset[:author][:uuid],
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

    render json: results_data.to_json
  end

  def asset
    params.permit!
    super
  end

  def create
    params.permit!
    super
  end

  def rate
    params.permit!
    super
  end

  def asset_set(var = :asset, limit = 30)
    params.permit!
    super
  end

  def update
    params.permit!
    super
  end

  def show
    @asset, @access_level = asset_with_access_level

    if @asset
      @title = @asset.title

      # Don't wait
      Thread.new do
        View.record_view(session_node,
                         @asset,
                         browser_string: request.env['HTTP_USER_AGENT'],
                         ip_address: request.remote_ip)
        puts 'ending view thread'
      end
    else
      render file: 'public/404.html', status: :not_found, layout: false
    end
  end

  def show_source
    params[:model_slug] = "graph_gists"
    @asset, _ = asset_with_access_level

    render file: 'public/404.html', status: :not_found, layout: false unless @asset
  end

  def edit_graph_gists_by_owner
    params.permit!
    params[:model_slug] = "graph_gists"
    @liveAsset, @access_level = asset_with_access_level

    if @access_level != 'write'
      fail 'You don\'t have write access'
    end

    @asset = GraphGistCandidate.where(graphgist:  @liveAsset).to_a[0]
    if !@asset
      @asset = GraphGistCandidate.create_from_graphgist(@liveAsset)
    end

    @title = @asset.title.to_s + ' - Edit'

    render file: 'public/404.html', status: :not_found, layout: false if !@asset
  end

  def update_graph_gists_by_owner
    params.permit!
    params[:model_slug] = "graph_gists"
    @liveAsset, @access_level = asset_with_access_level

    if @access_level != 'write'
      fail 'You don\'t have write access'
    end

    @asset = @liveAsset.candidate
    if !@asset.update(params['graph_gist_candidate'])
      flash[:error] = @asset.errors.messages.to_a.map {|pair| pair.join(' ') }.join(' / ')
      return redirect_to :back
    end

    if ['candidate', 'draft'].include?(@liveAsset.status)
      @liveAsset.is_candidate_updated = false
      @liveAsset.update(params['graph_gist_candidate'])
    else
      @liveAsset.is_candidate_updated = true
      @liveAsset.save
    end

    redirect_to graph_edit_by_owner_step2_path(id: params[:id])
  end

  def edit_graph_gists_by_owner_step2
    params.permit!
    params[:model_slug] = "graph_gists"
    @liveAsset, @access_level = asset_with_access_level

    if @access_level != 'write'
      fail 'You don\'t have write access'
    end

    @asset = GraphGistCandidate.where(graphgist:  @liveAsset).to_a[0]
    if !@asset
      @asset = GraphGistCandidate.create_from_graphgist(@liveAsset)
    end

    @title = @asset.title.to_s + ' - Edit'

    render file: 'public/404.html', status: :not_found, layout: false if !@asset
  end

  def update_graph_gists_by_owner_step2
    params.permit!
    params[:model_slug] = "graph_gists"
    @liveAsset, @access_level = asset_with_access_level

    if @access_level != 'write'
      fail 'You don\'t have write access'
    end

    @asset = @liveAsset.candidate
    @asset.status = 'candidate'
    if !@asset.update(params['graph_gist_candidate'])
      flash[:error] = @asset.errors.messages.to_a.map {|pair| pair.join(' ') }.join(' / ')
      return redirect_to :back
    end

    if ['candidate', 'draft'].include?(@liveAsset.status)
      @liveAsset.is_candidate_updated = false
      @liveAsset.update(params['graph_gist_candidate'])
    else
      @liveAsset.is_candidate_updated = true
      @liveAsset.save
    end

    redirect_to graph_starter.asset_path(id: @asset.id, model_slug: 'graph_gist_candidates')
  end

  def asset_with_access_level
    params.permit!
    scope = model_class_scope.where('asset.uuid = {id} OR asset.slug = {id}', id: params[:id])
    if defined?(current_user)
      scope.pluck(:asset, :level)
    else
      scope.pluck(:asset, '"read"')
    end.to_a[0]
  end

  def make_graphgist_live
    fail 'Must be an admin user' if !current_user.admin?

    params.permit!
    params[:model_slug] = "graph_gists"
    live = asset
    if live.candidate.nil?
      candidate = GraphGistCandidate.create_from_graphgist(live)
    else
      candidate = live.candidate
    end

    live.asciidoc = candidate.asciidoc
    live.title = candidate.title
    live.url = candidate.url
    live.status = 'live'
    live.is_candidate_updated = false
    live.save
    candidate.status = live.status
    candidate.save
    redirect_to graph_starter.asset_path(id: live.slug, model_slug: 'graph_gists')
  end

  def make_graphgist_disabled
    fail 'Must be an admin user' if !current_user.admin?

    params.permit!
    params[:model_slug] = "graph_gists"
    live = asset
    if live.candidate.nil?
      candidate = GraphGistCandidate.create_from_graphgist(live)
    else
      candidate = live.candidate
    end

    live.status = 'disabled'
    live.save
    candidate.status = 'draft'
    candidate.save
    redirect_to graph_starter.asset_path(id: candidate.id, model_slug: 'graph_gist_candidates')
  end

  def make_graphgist_candidate
    params.permit!
    params[:model_slug] = "graph_gists"
    live, access_level = asset_with_access_level

    if access_level != 'write'
      fail 'You don\'t have write access'
    end

    if live.candidate.nil?
      candidate = GraphGistCandidate.create_from_graphgist(live)
    else
      candidate = live.candidate
    end

    live.status = 'candidate'
    live.save
    candidate.status = 'candidate'
    candidate.save

    redirect_to graph_starter.asset_path(id: live.id, model_slug: 'graph_gists')
  end

  def challenge_new
    params.permit!
    params[:model_slug] = "challenges"
    @asset = model_class.new
    fail 'Must be an admin user' if @asset.is_a?(Challenge) && !current_user.admin?
  end

  def challenge_create
    params.permit!
    params[:model_slug] = "challenges"
    fail 'Must be an admin user' if @asset.is_a?(Challenge) && !current_user.admin?

    @asset = model_class.create(params[params[:model_slug].singularize])

    if @asset.persisted?
      redirect_to graph_starter.asset_path(id: @asset.id, model_slug: params[:model_slug])
    else
      flash[:error] = @asset.errors.messages.to_a.map {|pair| pair.join(' ') }.join(' / ')
      redirect_to :back
    end
  end
end
