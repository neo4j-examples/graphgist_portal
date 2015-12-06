Feature: Redirects
  Scenario:
    When The URL http://gist.neo4j.org/?8bdcc380cbb240c7d17a is visited
    Then A redirect is given to http://neo4j.com/graphgist/?graphgist=8bdcc380cbb240c7d17a

  Scenario:
    When The URL http://gist.neo4j.org/?8019511 is visited
    Then A redirect is given to http://neo4j.com/graphgist/?graphgist=8019511

  Scenario:
    When The URL http://gist.neo4j.org/?github-HazardJ%2Fgists%2F%2FDoc_Source_Graph.adoc is visited
    Then A redirect is given to http://neo4j.com/graphgist/?graphgist=github-HazardJ%2Fgists%2F%2FDoc_Source_Graph.adoc

