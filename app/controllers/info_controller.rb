class InfoController < ApplicationController
  def featured_graphgists
    @featured_graphgists = GraphGist.featured.to_a
  end

  def about
  end

  def submit
  end
end
