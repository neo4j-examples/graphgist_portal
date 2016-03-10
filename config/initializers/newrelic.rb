if defined?(NewRelic)
  require 'new_relic/agent/datastores'

  module Neo4j
    module Server
      # Re-opening class to add newrelic monitoring
      class CypherSession < Neo4j::Session
        NewRelic::Agent::Datastores.trace self, :_query, 'Neo4j'
      end
    end
  end
end
