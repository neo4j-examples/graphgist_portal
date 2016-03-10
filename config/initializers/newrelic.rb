if defined?(NewRelic)
  require 'new_relic/agent/datastores'

  ActiveSupport::Notifications.subscribe('neo4j.cypher_query') do |_, start, finish, _id, payload|
    NewRelic::Agent::Datastores.notice_statement(payload[:cypher], finish - start)
  end
end
