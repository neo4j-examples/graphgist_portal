Feature: Renders gists by ID
  Scenario:
    When The path /render_graphgist?id=11289752 is visited
    Then A page with "Movie recommendation based on User preferences and Actor weights" is returned

  Scenario:
    When The path /render_graphgist?id=8bdcc380cbb240c7d17a is visited
    Then A page with "FactMiners and The Softalk Apple Project" is returned

  Scenario:
    When The path /render_graphgist?id=github-HazardJ%2Fgists%2F%2FDoc_Source_Graph.adoc is visited
    Then A page with "Model Agt Frame" is returned

  Scenario:
    When The path /render_graphgist?id=github-kbastani/gists//meta/TimeScaleEventMetaModel.adoc is visited
    Then A page with "Time Scale Event Meta Model" is returned

  Scenario:
    When The path /render_graphgist?id=dropbox-14493611/cypher-introduction.adoc is visited
    Then A page with "Cypher Introduction - Social Movie Database" is returned

  Scenario:
    When The path /render_graphgist?id=dropbox-2900504%2Fgist.adoc is visited
    Then A page with "Contributor Community Graph" is returned

  Scenario:
    When The path /render_graphgist?id=https%3A%2F%2Fgist.githubusercontent.com%2Frvanbruggen%2Fc82d0a68d32cf3067706%2Fraw%2Fe05fa4ff92c1822acac87593f058a06f0798f141%2FMiddle%2520East%2520GraphGist.adoc is visited
    Then A page with "Cypher Introduction - Social Movie Database" is returned

