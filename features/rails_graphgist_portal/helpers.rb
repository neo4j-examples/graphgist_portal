# Context variables for testing the Rails GraphGist portal
module RailsGraphgistPortal
  class << self
    attr_accessor :host
  end
end

RailsGraphgistPortal.host = 'http://portal.graphgist.org'
