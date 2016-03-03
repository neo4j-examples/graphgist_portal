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

window.CypherConsole = (config, ready) ->
  $IFRAME = $('<iframe/>').attr('id', 'console').addClass('cypherdoc-console')
  $IFRAME_WRAPPER = $('<div/>').attr('id', 'console-wrapper')
  RESIZE_OUT_ICON = 'ui expand icon'
  RESIZE_IN_ICON = 'ui large compress icon'
  $RESIZE_BUTTON = $('<a class="resize-toggle ui icon green button fi-arrows-expand"><i class="' + RESIZE_OUT_ICON + '"></i></a>')
  $RESIZE_VERTICAL_BUTTON = $('<span class="resize-vertical-handle ui-resizable-handle ui-resizable-s"><span/></span>')
  $PLAY_BUTTON = $('<a class="run-query ui green icon button" data-toggle="tooltip" title="Execute in the console." href="#"><i class="ui play icon"></i></a>')
  $EDIT_BUTTON = $('<a class="edit-query ui icon button" data-toggle="tooltip" title="Edit in the console." href="#"><i class="ui edit icon"></i></a>')
  $TOGGLE_CONSOLE_HIDE_BUTTON = $('<a class="show-console-toggle ui icon button" data-toggle="tooltip"  title="Show or hide a Neo4j Console in order to try the examples in the GraphGist live."><i class="ui edit icon"></i> Show/Hide Live Console</a>')
  $resizeOverlay = $('<div id="resize-overlay"/>')
  consolr = undefined
  consoleClass = if 'consoleClass' of config then config.consoleClass else 'console'
  contentId = if 'contentId' of config then config.contentId else 'content'
  contentMoveSelector = if 'contentMoveSelector' of config then config.contentMoveSelector else 'div.navbar'
  consoleUrl = config.url

  createConsole = (ready, elementClass, contentId) ->
    if $('code.language-cypher').length > 0
      $element = $('p.' + elementClass).first()
      if $element.length != 1
        #no console defined in the document
        $element = $('<p/>').addClass(elementClass)
        $('#' + contentId).append $element
        $element.hide()

      $element.each ->
        $context = $(this)
        addConsole $context, $('#' + contentId).data('gist-id'), ready

      addPlayButtons()
    else
      ready()
    return

  addConsole = ($context, gistId, ready) ->
    url = getUrl('none', 'none', '\n\nUse the play/edit buttons to run the queries!')
    $iframe = $IFRAME.clone().attr('src', url)
    $iframe.load ->
      iframeWindow = $iframe[0].contentWindow
      return if !iframeWindow

      consolr = new Consolr(iframeWindow, gistId)
      if ready
        ready consolr
      window.setTimeout (->
        try
          if iframeWindow.location and iframeWindow.location.href
            consoleLocation = iframeWindow.location.href
            if consoleLocation.indexOf('neo4j') == -1 and consoleLocation.indexOf('localhost') == -1
              $iframe.replaceWith '<div class="alert alert-error"><h4>Error!</h4>The console can not be loaded. Please turn off ad blockers and reload the page!</div>'
        catch err
          # for debugging only
          # console.log(err)
        return
      ), 2000

      return

    $context.empty()
    $iframeWrapper = $IFRAME_WRAPPER.clone()
    $iframeWrapper.append $iframe
    $contentMoveSelector = $(contentMoveSelector).first()
    $context.append($iframeWrapper).append '<span id="console-label" class="label">Console expanded</span>'
    $context.css 'background', 'none'
    $verticalResizeButton = $RESIZE_VERTICAL_BUTTON.clone().appendTo($iframeWrapper).mousedown((event) ->
      event.preventDefault()
      return
    )

    $iframeWrapper.resizable
      handles:
        s: $verticalResizeButton
      alsoResize: $context
      minHeight: 80
      start: ->
        $resizeOverlay.appendTo $iframeWrapper
        return
      stop: (event, ui) ->
        $resizeOverlay.detach()
        return
      resize: (event, ui) ->
        if !$resizeIcon.hasClass(RESIZE_OUT_ICON)
          $contentMoveSelector.css 'margin-top', ui.size.height + 11
        return
    $gistForm = $('#gist-form')
    contextHeight = 0
    $resizeButton = $RESIZE_BUTTON.clone().appendTo($iframeWrapper).click(->
      if $resizeIcon.hasClass(RESIZE_OUT_ICON)
        contextHeight = $context.height()
        $context.height 36
        $resizeIcon.removeClass(RESIZE_OUT_ICON).addClass RESIZE_IN_ICON
        $iframeWrapper.addClass 'fixed-console'
        $context.addClass 'fixed-console'
        $contentMoveSelector.css 'margin-top', $iframeWrapper.height() + 11
        $iframeWrapper.resizable 'option', 'alsoResize', null
        $gistForm.css 'margin-right', 56
      else
        $context.height $iframeWrapper.height()
        $resizeIcon.removeClass(RESIZE_IN_ICON).addClass RESIZE_OUT_ICON
        $iframeWrapper.removeClass 'fixed-console'
        $context.removeClass 'fixed-console'
        $contentMoveSelector.css 'margin-top', 0
        $iframeWrapper.resizable 'option', 'alsoResize', $context
        $gistForm.css 'margin-right', 0
        document.body.scrollTop = $iframeWrapper.offset().top - 100
      return
    )
    $resizeIcon = $('i', $resizeButton)
    $toggleConsoleShowButton = $TOGGLE_CONSOLE_HIDE_BUTTON
    $toggleConsoleShowButton.insertAfter $context
    if !$context.is(':visible')
      $toggleConsoleShowButton.addClass 'ui button green icon show-console-toggle-hidden-console'
    $toggleConsoleShowButton.click ->
      if $context.is(':visible')
        if !$resizeIcon.hasClass(RESIZE_OUT_ICON)
          $resizeButton.click()
        $context.hide()
        $toggleConsoleShowButton.addClass 'show-console-toggle-hidden-console'
      else
        $context.show()
        $toggleConsoleShowButton.removeClass 'show-console-toggle-hidden-console'
      return
    return

  addPlayButtons = ->
    $('div.query-wrapper').parent().append($PLAY_BUTTON.clone().click((event) ->
      event.preventDefault()
      consolr.query [ getQueryFromButton(this) ]
      return
    )).append $EDIT_BUTTON.clone().click((event) ->
      event.preventDefault()
      consolr.input getQueryFromButton(this)
      return
    )
    return

  getQueryFromButton = (button) ->
    $(button).prevAll('div.query-wrapper').first().data 'query'

  getUrl = (database, command, message, session) ->
    url = consoleUrl

    url += ';jsessionid=' + session if session?

    url += '?'

    url += 'init=' + encodeURIComponent(database) if database?

    url += '&query=' + encodeURIComponent(command) if command?

    url += '&message=' + encodeURIComponent(message) if message?

    url += '&version=' + encodeURIComponent(window.neo4jVersion) if window.neo4jVersion?

    url + '&no_root=true'

  createConsole ready, consoleClass, contentId

  return

window.Consolr = (consoleWindow, gistId) ->
  sessionId = undefined

  establishSession = ->
    $.get('/graph_gists/query_session_id', neo4j_version: '2.3').done (result) -> sessionId = result

  init = (params, success, error, data) ->

  query = (queries, success, error, final_success, always, call_id = 0) ->
    if queries.length
      $.get("/graph_gists/#{gistId}/query", gist_load_session: sessionId, neo4j_version: '2.3', cypher: queries[0]).done (result) ->
        data = JSON.parse(result)

        (if data.error then error else success)(data, call_id)

        query(queries[1..-1], success, error, final_success, always, call_id + 1)
      .fail ->
        always()
    else
      final_success()
      always()

  {
    establishSession: establishSession
    init: init
    query: query
  }

'use strict'

