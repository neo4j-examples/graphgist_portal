class QueryController < ApplicationController

  CONSOLE_HOSTS = {
    '1.9' => 'neo4j-console-19.herokuapp.com',
    '2.0' => 'neo4j-console-20.herokuapp.com',
    '2.1' => 'neo4j-console-21.herokuapp.com',
    '2.2' => 'neo4j-console-22.herokuapp.com',
    '2.3' => 'neo4j-console-23.herokuapp.com'
  }

  before_action :access_control_allow_all

  def graph_gist_query_session_id
    session_id = SecureRandom.uuid
    last_cache_keys[session_id] = nil

    # console_request(:init, params[:neo4j_version], '{"init":"none","query":"none","message":"none","viz":"none","no_root":true}:', session_id)
    console_request(:init, params[:neo4j_version], '{"init":"none"}', session_id).tap do |result|
      # Proxying cookies from console app
      raw_cookie = result.env.dig('response_headers', 'set-cookie')
      puts 'raw_cookie', raw_cookie.inspect
      if raw_cookie.present?
        _, name, value, expires = raw_cookie.match(/^([^=]+)=([^;]+).*Expires=([^;]+);/).to_a
        expires = DateTime.parse(expires)
        cookies["graphgist-query-#{name}"] = {value: value, expires: expires}
      end
    end

    render text: session_id
  end

  # gist_load_session given when loading gist?
  # GET /graph_gists/:graphgist_id/query?gist_load_session=something&neo4j_version=2.3&cypher=string
  def graph_gist_query
    result = handle_cache(*params.values_at(:graphgist_id, :cypher, :neo4j_version, :gist_load_session)) do
      fetch_query(*params.values_at(:cypher, :neo4j_version, :gist_load_session))
    end

    render text: result
  rescue BadResultError => e
    puts e.message
    render '', status: 500
  end

  private

  ALLOWED_HOSTS = %w(neo4j.com neo4jdotcom localhost)
  def access_control_allow_all
    response.headers['Access-Control-Allow-Credentials'] = 'true'
    if request.env['HTTP_ORIGIN'].present?
      http_origin_uri = URI(request.env['HTTP_ORIGIN'])
      if ALLOWED_HOSTS.include?(http_origin_uri.host)
        response.headers['Access-Control-Allow-Origin'] = "#{http_origin_uri.scheme}://#{http_origin_uri.host}"
      end
    end
  end

  def handle_cache(id, cypher, neo4j_version, session_id)
    graph_gist = GraphGist.find_by(id: id)
    if graph_gist && graph_gist.cached?
      cache_key = "#{last_cache_key}#{id}#{Digest::SHA256.base64digest(cypher)}#{neo4j_version}"

      Rails.cache.fetch(cache_key) { yield }.tap do
        last_cache_keys[session_id] = cache_key
      end
    else
      yield
    end
  end

  class BadResultError < StandardError; end
  def fetch_query(cypher, neo4j_version, gist_load_session)
    console_request(:cypher, neo4j_version, cypher, gist_load_session).tap do |result|
      if !(200..299).include?(result.status)
        fail BadResultError, "Got status: #{result.status}, expected a 2XX status"
      end
    end.body
  end

  def console_request(type, neo4j_version, cypher, session_id)
    url = "http://#{host_for_version(neo4j_version)}/console/#{type}"

    result = nil
    time = Benchmark.realtime do
      # Proxying cookies from console app
      cookie_header = cookies.to_h.keys.grep(/^graphgist-query-/).map { |key| "#{key[16..-1]}=#{cookies[key]}" }.join('; ')

      result = Faraday.post(url, cypher, 'X-Session': session_id, 'Cookie': cookie_header)
    end

    Rails.logger.info "  Request to #{url} took #{(time * 1000.0).round(1)}ms"

    result
  end

  def host_for_version(neo4j_version)
    CONSOLE_HOSTS[neo4j_version] || CONSOLE_HOSTS[CONSOLE_HOSTS.keys.sort_by(&:to_f).last]
  end

  def last_cache_key
    last_cache_keys.fetch(params[:gist_load_session])
  end

  def last_cache_keys
    session[:last_cache_keys] ||= {}
  end
end
