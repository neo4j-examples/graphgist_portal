# For fonts to work
class CorsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    cors_headers = headers.dup
    if env['REQUEST_PATH'].match(/woff2$/)
      cors_headers = cors_headers.merge(
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Request-Method' => '*'
      )
      puts 'cors_headers', cors_headers.inspect
    end
    [status, cors_headers, body]
  end
end
