Feature: Renders gists by ID
  Scenario:
    When The path /graph_gists/by_graphgist_id/11289752.html is visited
    Then A page with "Movie recommendation based on User preferences and Actor weights" is returned

  Scenario:
    When The path /graph_gists/by_graphgist_id/8bdcc380cbb240c7d17a.html is visited
    Then A page with "FactMiners and The Softalk Apple Project" is returned

  Scenario:
    When The path /graph_gists/by_graphgist_id/github-HazardJ%2Fgists%2F%2FDoc_Source_Graph.adoc.html is visited
    Then A page with "Model Agt Frame" is returned

  Scenario:
    When The path /graph_gists/by_graphgist_id/github-kbastani/gists//meta/TimeScaleEventMetaModel.adoc.html is visited
    Then A page with "Time Scale Event Meta Model" is returned

  Scenario:
    When The path /graph_gists/by_graphgist_id/dropbox-14493611/cypher-introduction.adoc.html is visited
    Then A page with "Cypher Introduction - Social Movie Database" is returned

  Scenario:
    When The path /graph_gists/by_graphgist_id/dropbox-2900504%2Fgist.adoc.html is visited
    Then A page with "Contributor Community Graph" is returned

  Scenario:
    When The path /graph_gists/by_graphgist_id/https%3A%2F%2Fgist.githubusercontent.com%2Frvanbruggen%2Fc82d0a68d32cf3067706%2Fraw%2Fe05fa4ff92c1822acac87593f058a06f0798f141%2FMiddle%2520East%2520GraphGist.adoc.html is visited
    Then A page with "Friend-or-Foe Relations in the Middle East" is returned

  # JSON
  Scenario:
    When The path /graph_gists/by_graphgist_id/11289752.json is visited
    Then JSON is returned having a key 'html' which contains 'Given a movie database'
    Then JSON is returned having a key 'title' which contains 'Movie recommendation based on User preferences and Actor weights'

  Scenario:
    When The path /graph_gists/by_graphgist_id/github-kbastani/gists//meta/TimeScaleEventMetaModel.adoc.json is visited
    Then JSON is returned having a key 'html' which contains 'many questions were asked about how to handle temporal or time-based traversals in a Neo4j graph'
    Then JSON is returned having a key 'title' which contains 'Time Scale Event Meta Model'


