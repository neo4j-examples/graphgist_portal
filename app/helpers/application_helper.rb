module ApplicationHelper
  include GraphStarter::ApplicationHelper

  # Copied from https://github.com/dongli/mathjax-rails
  # PR has been sitting there for a while...
  def mathjax_tag(opt = {})
    opt[:config] ||= 'TeX-AMS_HTML-full.js'
    opt[:config] = nil if opt[:config] == false

    route_method = opt[:absolute_path] ? :mathjax_url : :mathjax_path
    "<script src=\"#{main_app.send(route_method, uri: 'MathJax.js', config: opt[:config])}\" type=\"text/javascript\"></script>".html_safe
  end
end
