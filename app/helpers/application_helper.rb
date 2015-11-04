module ApplicationHelper
  include GraphStarter::ApplicationHelper

  # Copied from https://github.com/dongli/mathjax-rails
  # PR has been sitting there for a while...
  def mathjax_tag(opt = {})
    opt[:config] ||= 'TeX-AMS_HTML-full.js'
    opt[:config] = nil if opt[:config] == false
    "<script src=\"#{main_app.mathjax_path(uri: 'MathJax.js', config: opt[:config])}\" type=\"text/javascript\"></script>".html_safe
  end
end

