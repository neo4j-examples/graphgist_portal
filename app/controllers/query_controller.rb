class QueryController < ApplicationController

  CONSOLE_HOSTS = {
    '1.9' => 'neo4j-console-19.herokuapp.com',
    '2.0' => 'neo4j-console-20.herokuapp.com',
    '2.1' => 'neo4j-console-21.herokuapp.com',
    '2.2' => 'neo4j-console-22.herokuapp.com',
    '2.3' => 'neo4j-console-23.herokuapp.com'
  }

  def graph_gist_query_session_id
    session_id = SecureRandom.uuid
    last_cache_keys[session_id] = nil

    console_request(:init, params[:neo4j_version], '', session_id)

    render text: session_id
  end

  # gist_load_session given when loading gist?
  # GET /graph_gists/:graphgist_id/query?gist_load_session=something&neo4j_version=2.3&cypher=string
  def graph_gist_query
    result = handle_cache(*params.values_at(:graphgist_id, :cypher, :gist_load_session)) do
      fetch_query(*params.values_at(:cypher, :neo4j_version, :gist_load_session))
    end


    render text: result
  rescue BadResultError => e
    puts e.message
    render '', status: 500
  end

  private

  def handle_cache(id, cypher, session_id)
    if GraphGist.find(id).cached?
      cache_key = "#{last_cache_key}#{id}#{Digest::SHA256.base64digest(cypher)}"

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
      result = Faraday.post(url, cypher, 'X-Session': session_id)
    end

    Rails.logger.info "Request to #{url} took #{time.round(3)}s"

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
