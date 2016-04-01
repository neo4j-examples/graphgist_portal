# For fonts to work
class CorsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    new_headers = headers.dup

    if env['PATH_INFO'] && env['PATH_INFO'].match(/woff2$/)
      new_headers = new_headers.merge(
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Request-Method' => '*'
      )
    end
    [status, new_headers, body]
  end
end
