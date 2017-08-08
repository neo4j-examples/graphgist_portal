class AssetsController < ::GraphStarter::AssetsController

  def index
    if (%w(industries use_cases challenges people).include? params[:model_slug]) and !(current_user&.admin?)
      fail 'Must be an admin user'
    end
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

  def edit_graph_gists_by_owner
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
    params[:model_slug] = "graph_gists"
    @liveAsset, @access_level = asset_with_access_level

    if @access_level != 'write'
      fail 'You don\'t have write access'
    end

    @asset = @liveAsset.candidate
    @asset.update(params['graph_gist_candidate'])

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
    scope = model_class_scope.where('asset.uuid = {id} OR asset.slug = {id}', id: params[:id])
    if defined?(current_user)
      scope.pluck(:asset, :level)
    else
      scope.pluck(:asset, '"read"')
    end.to_a[0]
  end

  def make_graphgist_live
    fail 'Must be an admin user' if !current_user.admin?

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
    params[:model_slug] = "challenges"
    @asset = model_class.new
    fail 'Must be an admin user' if @asset.is_a?(Challenge) && !current_user.admin?
  end

  def challenge_create
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
