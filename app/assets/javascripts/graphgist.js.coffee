###*
# Licensed to Neo Technology under one or more contributor license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright ownership. Neo Technology licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You
# may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
###

window.GraphGist = ($, options) ->

  HAS_ERRORS = false
  $WRAPPER = $('<div class="query-wrapper" />')
  COLLAPSE_ICON = 'ui large compress icon fi-arrows-compress'
  EXPAND_ICON = 'ui large expand icon fi-arrows-expand'
  $QUERY_OK_LABEL = $('<span class="label label-success query-info">Test run OK</span>')
  $QUERY_ERROR_LABEL = $('<span class="label label-important query-info">Test run Error</span>')
  $TOGGLE_BUTTON = $('<span data-toggle="tooltip"><i class="' + COLLAPSE_ICON + '"></i></span>')
  $QUERY_TOGGLE_BUTTON = $TOGGLE_BUTTON.clone().addClass('query-toggle').attr('title', 'Show/hide query.')
  $RESULT_TOGGLE_BUTTON = $TOGGLE_BUTTON.clone().addClass('result-toggle').attr('title', 'Show/hide result.')
  $RESULT_BOX = $('<div class="result-box"><i class="ui share alternate icon"></div>')
  $QUERY_MESSAGE = $('<pre/>').addClass('query-message')
  $VISUALIZATION = $('<div/>').addClass('visualization')
  VISUALIZATION_HEIGHT = 400
  $TABLE_CONTAINER = $('<div/>').addClass('result-table')
  DEFAULT_SOURCE = 'github-neo4j-contrib%2Fgists%2F%2Fmeta%2FHome.adoc'
  $VISUALIZATION_ICONS = $('<div class="visualization-icons"><i class="ui large expand icon fi-arrows-expand" title="Toggle fullscreen mode"></i></div>')
  $I = $('<i/>')
  DEFAULT_VERSION = '2.3'
  CONSOLE_VERSIONS = 
    '2.0.0-M06': 'http://neo4j-console-20m06.herokuapp.com/'
    '2.0.0-RC1': 'http://neo4j-console-20rc1.herokuapp.com/'
    '2.1': 'http://neo4j-console-21.herokuapp.com/'
    '2.2': 'http://neo4j-console-22.herokuapp.com/'
    '2.3': 'http://neo4j-console-23.herokuapp.com/'
    'local': 'http://localhost:8080/'
    '1.9': 'http://neo4j-console-19.herokuapp.com/'
  neod3Renderer = new Neod3Renderer
  $content = undefined
  $gistId = undefined
  consolr = undefined
  content_id = 'gist-body'
  #$(document).ready(function () {
  $content = $('#' + content_id)
  $gistId = $('#gist-id')
  gist = new Gist($, $content)
  #gist.getGistAndRenderPage(renderContent, DEFAULT_SOURCE);
  $gistId.keydown gist.readSourceId
  #});


  querySearchParams = ->
    searchParams = {}
    location.search.substr(1).split('&').forEach (item) ->
      searchParams[item.split('=')[0]] = item.split('=')[1]
      return
    searchParams

  renderContent = ->
    #var version;
    #var $meta = $('#metadata', $content);
    #var version = $meta.attr('version'), tags = $meta.attr('tags'), author = $meta.attr('author'), twitter = $meta.attr('twitter');
    #if (typeof version === 'undefined' || !(version in CONSOLE_VERSIONS)) {
    #    version = DEFAULT_VERSION;
    #}
    version = postProcessPage()
    consoleUrl = CONSOLE_VERSIONS[if version of CONSOLE_VERSIONS then version else DEFAULT_VERSION]
    if querySearchParams()['use_test_console_server'] == 'true'
      consoleUrl = 'http://neo4j-console-test.herokuapp.com/'
    CypherConsole {
      url: consoleUrl
      neo4j_version: version
      contentId: content_id
    }, (conslr) ->
      consolr = conslr
      consolr.establishSession?().done ->
        executeQueries (->), postProcessRendering
        return
      return
    return

  postProcessRendering = ->
    #$('span[data-toggle="tooltip"]').tooltip({'placement': 'left'});
    #$('a.run-query,a.edit-query,a.show-console-toggle').tooltip({'placement': 'right'});
    #$('.tooltip-below').tooltip({'placement': 'bottom'});
    $status = $('#status')
    if HAS_ERRORS
      $status.text 'Errors.'
      $status.addClass 'label-important'
    else
      $status.text 'No Errors.'
      $status.addClass 'label-success'
    DotWrapper($).scan()
    #initDisqus($content);
    return

  processMathJAX = ->
    MathJax.Hub.Queue [
      'Typeset'
      MathJax.Hub
    ]
    return

  formUrl = (url, title, author, twitter) ->
    'https://docs.google.com/forms/d/1blgZoRZ6vLbpnqdJx3b5c4BkO_mgmD-hgdRQTMm7kc4/viewform?entry.718349727=' + encodeURIComponent(url) + '&entry.1981612324=' + encodeURIComponent(if title.length > 18 then title.substr(0, title.length - 18) else title) + '&entry.1328778537=' + encodeURIComponent(author) + '&entry.507462214=' + encodeURIComponent(twitter)

  initAndGetHeading = ->
    headingText = 'Neo4j GraphGist'
    heading = $('h1').first()
    if !heading.length
      heading = $('h2').first()
    if heading.length
      headingText = heading.text()
      #            document.title = headingText + ' - Neo4j GraphGist';
    headingText

  postProcessPage = ->
    $meta = $('#metadata', $content)
    version = $meta.attr('version')
    tags = $meta.attr('tags')
    author = $meta.attr('author')
    twitter = $meta.attr('twitter')
    regex = /^(\d+)\.(\d+)\.\d+$/
    if typeof version != 'undefined' and version.match(regex)
      version = version.replace(regex, '$1.$2')
    if tags == '{tags}'
      tags = false
    if author == '{author}'
      author = false
    if twitter == '{twitter}'
      twitter = false
    if typeof version == 'undefined' or !(version of CONSOLE_VERSIONS)
      version = DEFAULT_VERSION
    $footer = $('footer')
    if tags
      $footer.prepend '<i class="icon-tags"></i> Tags <em>' + tags + '</a> '
    if twitter
      twitter = twitter.replace('@', '')
    if twitter and !author
      author = twitter
    if author
      authorHtml = '<i class=' + (if twitter then '"icon-twitter-sign"' else '"icon-user"') + '></i> Author '
      if twitter
        authorHtml += '<a target="_blank" href="http://twitter.com/' + twitter + '">'
      authorHtml += author
      if twitter
        authorHtml += '</a>'
      authorHtml += ' '
      $footer.prepend authorHtml
    $footer.prepend '<i class="icon-check"></i><a target="_blank" title="Submit an original GraphGist and get a Neo4j t-shirt" href="' + formUrl(window.location.href, document.title, author, twitter) + '"> Submit</a> '
    $footer.prepend '<i class="icon-cogs"></i> Uses Neo4j Version <a target="_blank" href="http://docs.neo4j.org/chunked/' + version + '/cypher-query-lang.html">' + version + '</a> '
    $('h2[id]').css(cursor: 'pointer').click ->
      window.location.href = window.location.href.replace(/($|#.+?$)/, '#' + $(this).attr('id'))

    processMathJAX()
    findQuery 'span.hide-query', $content, (codeElement) ->
      $(codeElement.parentNode).addClass 'hide-query'

    findQuery 'span.setup', $content, (codeElement) ->
      $(codeElement.parentNode).addClass 'setup-query'

    findQuery 'span.query-output', $content, (codeElement) ->
      $(codeElement.parentNode).data 'show-output', true

    number = 0
    # Can maybe drop this.  Prism stuff
    $('code', $content).each (index, el) ->
      $el = $(el)
      if $el.hasClass('language-cypher')
        number++
        $parent = $el.parent()
        $parent.addClass 'with-buttons'
        $el.attr 'data-lang', 'cypher'
        $parent.prepend '<h5>Query ' + number + '</h5>'
        $el.wrap($WRAPPER).each ->
          $el.parent().data 'query', $el.text()

        $RESULT_BOX.clone().insertAfter($el.parents('pre.language-cypher'))

        $toggleQuery = $QUERY_TOGGLE_BUTTON.clone()
        $parent.append $toggleQuery
        $toggleQuery.click ->
          $icon = $('i', this)
          $queryWrapper = $icon.parent().prevAll('div.query-wrapper').first()
          action = toggler($queryWrapper, this)
          if action == 'hide'
            $queryMessage = $queryWrapper.nextAll('pre.query-message').first()
            $icon = $queryWrapper.nextAll('span.result-toggle').first()
            toggler $queryMessage, $icon, 'hide'
          return
        if $parent.hasClass('hide-query')
          $wrapper = $toggleQuery.prevAll('div.query-wrapper').first()
          toggler $wrapper, $toggleQuery, 'hide'

    $('pre code.language-cypher').addClass 'cm-s-neo'
    code_els = $('pre code.language-cypher').toArray()
    for i of code_els
      code_el = code_els[i]
      CodeMirror.runMode $(code_el).text(), 'cypher', code_el
    $('table').addClass 'table'
    # bootstrap formatting
    version

  initConsole = (callback, always) ->
    query = getSetupQuery()

    success = (data) ->
      consolr.input ''
      if callback
        callback()
      if always
        always()
      return

    error = (data) ->
      HAS_ERRORS = true
      console.log 'Error during INIT: ', data
      if always
        always()
      return

    consolr.init {
      'init': 'none'
      'query': query or 'none'
      'message': 'none'
      'viz': 'none'
      'no_root': true
    }, success, error
    return

  executeQueries = (final_success, always) ->

    success = (data, $element) ->
      showOutput = $element.parent().data('show-output')
      createQueryResultButton $QUERY_OK_LABEL, $element, data.result, !showOutput
      $element.data 'visualization', data['visualization']
      $element.data 'data', data
      renderTable($element, data)
      return

    error = (data, $element) ->
      HAS_ERRORS = true
      createQueryResultButton $QUERY_ERROR_LABEL, $element, data.error, false
      return

    $elements = $('div.query-wrapper')
    $elements.each (index, element) ->
      $element = $(element)
      statement = $element.data('query')

      consolr.query statement, $element, success, error, final_success, always

    always() if !$elements.length


  $('#console-template .run').click ->
    cypher = $('#console-template .cypher').val()


  getSetupQuery = ->
    queries = []
    $('#content pre.highlight.setup-query > div.query-wrapper').each ->
      $wrapper = $(this)
      query = $.trim($wrapper.data('query'))
      if query.length == 0
        return true
      if query.slice(-1) == ';'
        query = query.slice(0, -1)
      queries.push $.trim(query)
      $wrapper.prevAll('h5').first().each ->
        $heading = $(this)
        $heading.text $heading.text() + ' — this query has been used to initialize the console'
        return
      return
    if queries.length == 0 then undefined else queries.join(';\n')

  most_recent_visulization_number = 0

  renderGraphs = ->
    counter = 0
    findPreviousQueryWrapper 'h5.graph-visualization', $content, ($heading, $wrapper) ->
      visualization = $wrapper.data('visualization')
      id = 'graph-visualization-' + counter++
      $visContainer = $VISUALIZATION.clone().attr('id', id).insertAfter($heading)
      style = $heading.attr('data-style')
      show_result_only = $heading.attr('graph-mode') and $heading.attr('graph-mode').indexOf('result') != -1
      selectedVisualization = handleSelection(visualization, show_result_only)

      performVisualizationRendering = ->

        fullscreenClick = ->
          if $visContainer.hasClass('fullscreen')
            $('body').unbind 'keydown', keyHandler
            contract()
          else
            expand()
            $('body').keydown keyHandler

        expand = ->
          $visContainer.addClass 'fullscreen'
          $visContainer.height '100%'
          subscriptions.expand?()

        contract = ->
          $visContainer.removeClass 'fullscreen'
          $visContainer.height 400
          subscriptions.contract?()

        sizeChange = ->
          subscriptions.sizeChange?()

        keyHandler = (event) ->
          contract() if 'which' of event and event.which == 27

        if visualization
          rendererHooks = neod3Renderer.render(id, $visContainer, selectedVisualization, style)
          subscriptions = if 'subscriptions' of rendererHooks then rendererHooks['subscriptions'] else {}
          actions = if 'actions' of rendererHooks then rendererHooks['actions'] else {}
          $visualizationIcons = $VISUALIZATION_ICONS.clone().appendTo($visContainer)
          $visualizationIcons.children('i.fullscreen-icon').click fullscreenClick
          for iconName of actions
            actionData = actions[iconName]
            $I.clone().addClass(iconName).attr('title', actionData.title).appendTo($visualizationIcons).click actionData.func
          $visContainer.mutate 'width', sizeChange
        else
          $visContainer.text('There is no graph to render.').addClass 'alert-error'
        return

      $heading.remove()
      $visContainer.height VISUALIZATION_HEIGHT
      performVisualizationRendering()

  renderGraph = ($element, data) ->
    most_recent_visulization_number++
    $visContainer = $VISUALIZATION.clone().attr('id', "graph-visualization-#{counter}")
    $element.parents('.content').find('.result-box').append($visContainer)

  handleSelection = (data, show_result_only) ->
    return data if !show_result_only

    nodes = []
    links = []
    i = undefined
    i = 0
    while i < data.nodes.length
      node = data.nodes[i]
      if node.selected
        node['$index'] = nodes.length
        nodes.push node
      i++
    hasSelectedRels = data.links.filter((link) ->
      link.selected
    ).length > 0
    i = 0
    while i < data.links.length
      link = data.links[i]
      if link.selected or !hasSelectedRels and data.nodes[link.source].selected and data.nodes[link.target].selected
        link.source = data.nodes[link.source]['$index']
        link.target = data.nodes[link.target]['$index']
        links.push link
      i++
    {
      nodes: nodes
      links: links
    }

  renderTable = ($element, data) ->
    $tableContainer = $element.parents('.content').find('.result-box').append($TABLE_CONTAINER.clone())

    # cypher.datatable
    if !window.renderTable($tableContainer, data)
      $tableContainer.text('Couldn\'t render the result table.').addClass 'alert-error'


  replaceNewlines = (str) ->
    str.replace /\\n/g, '&#013;'

  createQueryResultButton = ($labelType, $wrapper, message, hide) ->
    $label = $labelType.clone()
    $button = $RESULT_TOGGLE_BUTTON.clone()
    $wrapper.after($label).after $button
    $message = $QUERY_MESSAGE.clone().text(replaceNewlines(message))

    toggler $message, $button, (if hide then 'hide' else 'show')

    $button.click -> toggler $message, $button

    $wrapper.after $message

  toggler = ($target, button, action) ->
    $icon = $('i', button)
    stateIsExpanded = $icon.hasClass(COLLAPSE_ICON)
    if action and action == 'hide' or action == undefined and stateIsExpanded
      $target.hide()
      $icon.removeClass(COLLAPSE_ICON).addClass EXPAND_ICON
      'hide'
    else
      $target.show()
      $icon.removeClass(EXPAND_ICON).addClass COLLAPSE_ICON
      'show'

  findQuery = (selector, context, operation) ->
    $(selector, context).each ->
      $(this).nextAll('div.listingblock').children('div').children('pre.highlight').children('code.language-cypher').first().each ->
        operation this
        return
      return
    return

  findPreviousQueryWrapper = (selector, context, operation) ->
    $(selector, context).each ->
      $selected = $(this)
      findPreviousQueryWrapperSearch $selected, $selected, operation
      return
    return

  findPreviousQueryWrapperSearch = ($container, $selected, operation) ->
    done = false
    done = findQueryWrapper($container, $selected, operation)
    return true if done

    $newContainer = $container.prev()
    if $newContainer.length
      return findPreviousQueryWrapperSearch($newContainer, $selected, operation)
    else
      $up = $container.parent()
      done = $up.length == 0 or $up.prop('tagName').toUpperCase() == 'BODY'
      if !done
        return findPreviousQueryWrapperSearch($up, $selected, operation)
    done

  findQueryWrapper = ($container, $selected, operation) ->
    done = false
    $container.find('div.query-wrapper').last().each ->
      operation $selected, $(this)
      done = true
      return
    done

  errorMessage = (message, gist) ->
    messageText = undefined
    if gist
      messageText = "Something went wrong fetching the GraphGist "#{gist}":<p>#{message}</p>"
    else
      messageText = "<p>#{message}</p>"

    $content.html "<div class=\"alert alert-block alert-error\"><h4>Error</h4>#{messageText}</div>"
    return

  if typeof options != 'undefined'
    options = {}
  if typeof options.preProcess != 'undefined'
    options.preProcess = true
  if 'support' of $
    $.support.cors = true

  {renderContent}

'use strict'
window.GraphGistRenderer = GraphGist(jQuery, preProcess: false)
Opal = {}

