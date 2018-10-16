# For fonts to work
class CorsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new env
    http_origin_uri = request.env['HTTP_ORIGIN'].present? && request.env['HTTP_ORIGIN']

    status, headers, body = @app.call(env)
    new_headers = headers.dup
    new_headers = new_headers.merge(
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Allow-Methods' => 'GET, OPTIONS'
    )

    if http_origin_uri
      new_headers = new_headers.merge(
        'Access-Control-Allow-Credentials' => 'true',
        'Access-Control-Allow-Origin' => "#{http_origin_uri}"
      )
    end

    [status, new_headers, body]
  end
end
