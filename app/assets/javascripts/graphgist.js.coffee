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

$.fn.goTo = ->
    $('html, body').animate
      scrollTop: "#{$(this).offset().top - 60}px"
    , 'fast'

    @ # for chaining...

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
  $QUERY_MESSAGE = $('<pre/>').addClass('query-message')
  $VISUALIZATION = $('<div/>').addClass('visualization')
  VISUALIZATION_HEIGHT = 400
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
    '3.0': 'http://neo4j-console-30.herokuapp.com/'
    '3.1': 'http://neo4j-console-31.herokuapp.com/'
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
  $gistId.keydown gist.readSourceId
  $console_template = $('#console-template')
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
    if graphgist_cached_queries?
        executeQueries (->), postProcessRendering
    else
      CypherConsole {
        url: consoleUrl
        neo4j_version: version
        contentId: content_id
        $console_template: $console_template
      }, (conslr) ->
        if typeof conslr != 'undefined'
          consolr = conslr
          consolr.establishSession?().done ->
            executeQueries (->), postProcessRendering

  postProcessRendering = ->
    $status = $('#status')
    if HAS_ERRORS
      $status.text 'Errors.'
      $status.addClass 'label-important'
    else
      $status.text 'No Errors.'
      $status.addClass 'label-success'
    DotWrapper($).scan()

  #processMathJAX = ->
  #  MathJax.Hub.Queue [
  #    'Typeset'
  #    MathJax.Hub
  #  ]
  #  return

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

    #processMathJAX()
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

  # Starting with an element, this finds the next element
  # going down the page, browsing the hierachy to find it
  find_next_globally = (element, selector) ->
    current_element = element
    while current_element
      $current_element = $(current_element)

      $matching_siblings = $current_element.nextAll(selector)
      return $matching_siblings[0] if $matching_siblings.length

      for sibling in $current_element.nextAll()
        $matching_cousins = $(sibling).find(selector)

        return $matching_cousins[0] if $matching_cousins.length

      current_element = $current_element.parent()[0]

    null

  find_all_next_globally = (element, selector) ->
    current_element = element
    result = []
    while current_element
      $current_element = $(current_element)
      result = result.concat $current_element.nextAll(selector).get()

      for sibling in $current_element.nextAll()
        result = result.concat $(sibling).find(selector).get()

      current_element = $current_element.parent()[0]

    result


  find_between = (element1, element2, selector) ->
    element1_nexts = find_all_next_globally(element1, selector)
    element2_nexts = find_all_next_globally(element2, selector)

    if element1_nexts.length > element2_nexts.length
      _(element1_nexts).difference(element2_nexts)
    else
      _(element2_nexts).difference(element1_nexts)


  executeQueries = (final_success, always) ->

    $elements = $('div.query-wrapper')
    $elements.each (index, element) ->
      $element = $(element)
      statement = $element.data('query')

      success = (data) ->
        showOutput = $element.parent().data('show-output')
        createQueryResultButton $QUERY_OK_LABEL, $element, data.result, !showOutput
        $element.data 'visualization', data['visualization']
        $element.data 'data', data

        next_query_wrapper = find_next_globally($element, 'div.query-wrapper')

        table_elements = if next_query_wrapper?
          find_between($element, next_query_wrapper, '.result-table')
        else
          find_all_next_globally($element, '.result-table')

        for table_element in table_elements
          renderTable(table_element, data)

        visualization_elements = if next_query_wrapper?
          find_between($element, next_query_wrapper, '.graph-visualization')
        else
          find_all_next_globally($element, '.graph-visualization')

        for visualization_element in visualization_elements
          renderGraph(visualization_element, data)

      error = (data) ->
        HAS_ERRORS = true
        createQueryResultButton $QUERY_ERROR_LABEL, $element, data.error, false

      final_success = ->
        if $('p.console').length
          $('p.console').replaceWith $console_template.detach()

        $console_template.show()

      if graphgist_cached_queries?
        success(graphgist_cached_queries[index])
      else
        consolr.query statement, success, error, final_success, always

    if graphgist_cached_queries?
      $('p.console').hide()
    always() if !$elements.length

  display_result_section = (section_name) ->
    $console_template.find('.result').show()
    $console_template.find('.result > *').hide()
    $element = $console_template.find(".result > .#{section_name}")
    $element.show()

    $element

  current_display_result_tab_name = ->
    $console_template.find('.tabs .tab.active').data('name')

  $console_template.find('.run').click ->
    display_result_section 'loading'

    $console_template.goTo()

    statement = $console_template.find('.cypher').val()

    success = (data) ->
      display_result_tab_name = current_display_result_tab_name()

      $element = display_result_section 'graph'
      renderGraph($element, data, false)

      $element = display_result_section 'table'
      renderTable($element[0], data, false, searching: false, paging: false)

      display_result_section display_result_tab_name

    error = (data) ->
      $element = display_result_section 'error'
      $element.html("<pre>#{data.error}</pre>")

    consolr.query statement, success, error

  $console_template.find('.tabs .tab').click (event) ->
    $el = $(event.target)

    $console_template.find('.tabs .tab').removeClass('active')
    $el.addClass('active')

    display_result_section $el.data('name')

  most_recent_visulization_number = 0

  renderGraph = (visualization_element, data, replace = true) ->
    $visualization_element = $(visualization_element)
    most_recent_visulization_number++
    id = "graph-visualization-#{most_recent_visulization_number}"
    $visContainer = $VISUALIZATION.clone().attr('id', id)

    style = $visualization_element.attr('data-style')
    show_result_only = $visualization_element.attr('graph-mode') and $visualization_element.attr('graph-mode').indexOf('result') != -1

    selectedVisualization = handleSelection(data.visualization, show_result_only)

    if replace
      $visualization_element.replaceWith($visContainer)
    else
      $visualization_element.html('')
      $visualization_element.append($visContainer)

    $visContainer.height VISUALIZATION_HEIGHT

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

    if data
      $visualization_element.data('visualization', data)
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

    $visContainer



  handleSelection = (data, show_result_only) ->
    return data if !show_result_only

    links = []

    nodes = (node for node in data.nodes when node.selected)

    hasSelectedRels = data.links.filter((link) -> link.selected).length > 0

    for link in data.links
      if link.selected or !hasSelectedRels and data.nodes[link.source].selected and data.nodes[link.target].selected
        # link.source = data.nodes[link.source]['$index']
        # link.target = data.nodes[link.target]['$index']
        links.push link

    {nodes, links}

  $TABLE_CONTAINER = $('<div/>').addClass('result-table')

  renderTable = (table_element, data, replace = true, options = {}) ->
    $table_element = $(table_element)
    # cypher.datatable
    $table_container = $TABLE_CONTAINER.clone()
    if replace
      $table_element.replaceWith($table_container)
    else
      $table_element.html('')
      $table_element.append($table_container)

    if !window.renderTable($table_container, data, options)
      $table_container.text("Couldn't render the result table.").addClass 'alert-error'


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

