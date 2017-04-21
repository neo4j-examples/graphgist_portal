class AssetsController < ::GraphStarter::AssetsController
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
    @asset, @access_level = asset_with_access_level
    @title = @asset.title.to_s + ' - Edit'

    render file: 'public/404.html', status: :not_found, layout: false if !@asset
  end

  def update_graph_gists_by_owner
    params[:model_slug] = "graph_gists"
    @asset, @access_level = asset_with_access_level
    @asset.update(params[params[:model_slug].singularize])

    redirect_to action: :edit_graph_gists_by_owner
  end

  def asset_with_access_level
    scope = model_class_scope.where('asset.uuid = {id} OR asset.slug = {id}', id: params[:id])
    if defined?(current_user)
      scope.pluck(:asset, :level)
    else
      scope.pluck(:asset, '"read"')
    end.to_a[0]
  end
end
