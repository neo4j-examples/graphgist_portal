Feature: Renders gists by ID
  Scenario:
    When The URL http://neo4j.com/graphgist/11289752 is visited
    Then A page with "Movie recommendation based on User preferences and Actor weights" is returned
    Then A page with "Given a movie database, with a structure like" is returned

  Scenario:
    When The URL http://neo4j.com/graphgist/8bdcc380cbb240c7d17a is visited
    Then A page with "FactMiners and The Softalk Apple Project" is returned
    Then A page with "Exploring the Metamodel Subgraph of a FactMiners Fact Cloud" is returned

  Scenario:
    When The URL http://neo4j.com/graphgist/github-HazardJ%2Fgists%2F%2FDoc_Source_Graph.adoc is visited
    Then A page with "Model Agt Frame" is returned

  Scenario:
    When The URL http://neo4j.com/graphgist/github-kbastani/gists//meta/TimeScaleEventMetaModel.adoc is visited
    Then A page with "Time Scale Event Meta Model" is returned

  Scenario:
    When The URL http://neo4j.com/graphgist/https%3A%2F%2Fgist.githubusercontent.com%2Frvanbruggen%2Fc82d0a68d32cf3067706%2Fraw%2Fe05fa4ff92c1822acac87593f058a06f0798f141%2FMiddle%2520East%2520GraphGist.adoc is visited
    Then A page with "Friend-or-Foe Relations in the Middle East" is returned

  Scenario:
    When The URL http://neo4j.com/graphgist/bad_graphgist_id is visited
    Then A page with "Could not load GraphGist" is returned
    Then A page with "That gist was not found or not available" is returned

  # Gist has multiple files
  Scenario:
    When The URL http://neo4j.com/graphgist/b2110dd44b5a4b7f8a8e is visited
    Then A page with "Could not load GraphGist" is returned
    Then A page with "That gist was not found or not available" is returned


