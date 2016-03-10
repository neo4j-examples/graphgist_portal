require 'new_relic/agent/datastores'

module Neo4j
  module Server
    class CypherSession < Neo4j::Session
      NewRelic::Agent::Datastores.trace self, :_query, "Neo4j"
    end
  end
end

