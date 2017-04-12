module Neo4jConsole
  CONSOLE_HOSTS = {
    '1.9' => 'neo4j-console-19.herokuapp.com',
    '2.0' => 'neo4j-console-20.herokuapp.com',
    '2.1' => 'neo4j-console-21.herokuapp.com',
    '2.2' => 'neo4j-console-22.herokuapp.com',
    '2.3' => 'neo4j-console-23.herokuapp.com',
    '3.0' => 'neo4j-console-30.herokuapp.com',
    '3.1' => 'neo4j-console-31.herokuapp.com'
  }
  DEFAULT_CONSOLE_HOST = CONSOLE_HOSTS['2.3']

  def self.host_for_version(neo4j_version)
    CONSOLE_HOSTS[neo4j_version] || DEFAULT_CONSOLE_HOST
  end

  class Neo4jConsoleClient
    def initialize(neo4j_version)
      @neo4j_version = neo4j_version
    end

    # Starts a new neo4j console session.
    def init
      @session_id = SecureRandom.uuid
      request(:init, '{"init":"none"}')
    end

    # Run a cypher query against the neo4j console.
    def cypher(query)
      request(:cypher, query)
    end

    private

    def request(type, data)
      url = "http://#{Neo4jConsole.host_for_version(@neo4j_version)}/console/#{type}"
      Faraday.post(url, data, 'X-Session': @session_id)
    end
  end
end
