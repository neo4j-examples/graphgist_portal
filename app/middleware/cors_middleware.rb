# For fonts to work
class CorsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    new_headers = headers.dup
    new_headers = new_headers.merge(
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Allow-Method' => 'GET'
    )
    [status, new_headers, body]
  end
end
