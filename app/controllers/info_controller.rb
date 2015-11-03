class InfoController < ApplicationController
  def featured_graphgists
    @featured_graphgists = GraphGist.only_featured.to_a
  end

  def about
  end

  def submit
  end
end
