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

window.Gist = ($, $content) ->
  DROPBOX_PUBLIC_BASE_URL = 'https://dl.dropboxusercontent.com/u/'
  DROPBOX_PRIVATE_BASE_URL = 'https://www.dropbox.com/s/'
  DROPBOX_PRIVATE_API_BASE_URL = 'https://dl.dropboxusercontent.com/s/'
  RISEUP_BASE_URL = 'https://pad.riseup.net/p/'
  RISEUP_EXPORT_POSTFIX = '/export/txt'
  COPY_COM_PUBLIC_LINK = 'https://copy.com/'
  VALID_GIST = /^[0-9a-f]{5,32}\/?$/

  getGistAndRenderPage = (renderer, defaultSource) ->
    id = window.location.search

    success = (content, link, imagesdir) ->
      if successful
        return
      successful = true
      returnCount++
      renderer content, link, imagesdir
      return

    error = (message) ->
      console.log 'Error fetching', id, message
      returnCount++
      if !successful and returnCount == fetchers.length
        errorMessage message, id
      return

    if id.length < 2
      id = defaultSource
    else
      id = id.substr(1)
      idCut = id.indexOf('&')
      if idCut != -1
        id = id.substring(0, idCut)
      if id.length > 20 and id.substring(0, 4) == '_ga='
        id = defaultSource
    fetchers = []
    if window.location.hostname.indexOf('www.neo4j.org') != -1
      fetchers.push neo4jGistFetcher
    fetcher = fetchGithubGist
    if id.length > 8 and id.substr(0, 8) == 'dropbox-'
      fetcher = fetchPublicDropboxFile
    else if id.length > 9 and id.substr(0, 9) == 'dropboxs-'
      fetcher = fetchPrivateDropboxFile
    else if id.length > 7 and id.substr(0, 7) == 'github-'
      fetcher = fetchGithubFile
    else if !VALID_GIST.test(id)
      if id.indexOf('%3A%2F%2F') != -1
        fetcher = fetchAnyUrl
      else
        fetcher = fetchLocalSnippet
    fetchers.push fetcher
    returnCount = 0
    successful = false
    $.each fetchers, ->
      this id, success, error
      return
    return

  readSourceId = (event) ->
    if event.which != 13 and event.which != 9
      return
    event.preventDefault()
    $target = $(event.target)
    $target.blur()
    preview_gist_from_url $target.val()
    return

  preview_gist_from_url = (url) ->
    window.location.href = '/#!/gists/' + encodeURIComponent(encodeURIComponent(gist_uuid(jQuery.trim(url)))) + '?original_url=' + url
    return

  gist_uuid = (gist_string) ->
    internal = {}
    internal['sourceParsers'] =
      'GraphGist Portal':
        baseUrl: 'http://graphgist.neo4j.com/#!/gists/'
        parse: (gist, parts, baseUrl) ->
          useRestOfTheUrl '', baseUrl, gist
      'GitHub Gist':
        baseUrl: 'https://gist.github.com/'
        parse: (gist, parts) ->
          useGithubGist 4, parts.length - 1, parts
      'Raw GitHub Gist':
        baseUrl: 'https://gist.githubusercontent.com/'
        parse: (gist, parts) ->
          useGithubGist 5, 4, parts
      'GitHub Repository File':
        baseUrl: 'https://github.com/'
        parse: (gist, parts) ->
          useGithubRepoParts {
            'branch': 6
            'path': 7
          }, parts
      'Raw GitHub Repository File':
        baseUrl: [
          'https://raw.github.com/'
          'https://raw.githubusercontent.com/'
        ]
        parse: (gist, parts) ->
          useGithubRepoParts {
            'branch': 5
            'path': 6
          }, parts
      'Public Dropbox File':
        baseUrl: DROPBOX_PUBLIC_BASE_URL
        parse: (gist, parts, baseUrl) -> useRestOfTheUrl 'dropbox-', baseUrl, gist
      'Shared Private Dropbox File':
        baseUrl: DROPBOX_PRIVATE_BASE_URL
        parse: (gist, parts, baseUrl) -> useRestOfTheUrl 'dropboxs-', baseUrl, gist
      'Copy.com Public Link':
        baseUrl: COPY_COM_PUBLIC_LINK
        parse: (gist, parts, baseUrl) ->
          useRestOfTheUrl 'copy-', baseUrl, gist
      'Riseup Pad':
        baseUrl: RISEUP_BASE_URL
        parse: (gist, parts) ->
          if parts.length < 5
            return { 'error': 'No pad id in the URL.' }
          pad = parts[4]
          if pad.length < 1
            return { 'error': 'Missing pad id in the URL.' }
          { 'id': 'riseup-' + pad }
      'Etherpad':
        baseUrl: [
          'https://beta.etherpad.org/'
          'https://piratepad.ca/p/'
          'https://factor.cc/pad/p/'
          'https://pad.systemli.org/p/'
          'https://pad.fnordig.de/p/'
          'https://notes.typo3.org/p/'
          'https://pad.lqdn.fr/p/'
          'https://pad.okfn.org/p/'
          'https://beta.publishwith.me/p/'
          'https://tihlde.org/etherpad/p/'
          'https://tihlde.org/pad/p/'
          'https://etherpad.wikimedia.org/p/'
          'https://etherpad.fr/p/'
          'https://piratenpad.de/p/'
          'https://bitpad.co.nz/p/'
          'http://beta.etherpad.org/'
          'http://notas.dados.gov.br/p/'
          'http://free.primarypad.com/p/'
          'http://board.net/p/'
          'https://pad.odoo.com/p/'
          'http://pad.planka.nu/p/'
          'http://qikpad.co.uk/p/'
          'http://pad.tn/p/'
          'http://lite4.framapad.org/p/'
          'http://pad.hdc.pw/p/'
        ]
        parse: (gist, parts, baseUrl) ->
          `var gist_uuid`
          if gist.length <= baseUrl.length
            return { 'error': 'No pad id in the URL.' }
          baseParts = gist.split('/')
          pad = parts[baseParts.length - 1]
          if pad.length < 1
            return { 'error': 'Missing pad id in the URL.' }
          basePrefix = if gist.indexOf('https') == 0 then 'eps' else 'ep'
          prefix = ''
          if gist.indexOf('/p/') != -1
            prefix = 'p'
          # intentionally no else
          if gist.indexOf('/pad/p/') != -1
            prefix = 'pp'
          else if gist.indexOf('/etherpad/p/') != -1
            prefix = 'ep'
          prefix = basePrefix + prefix + '-'
          { 'id': prefix + baseParts[2] + '-' + pad }
    gist_uuid = undefined
    if gist_string.indexOf('/') != -1
      if gist_string.indexOf('#') != -1
        split = gist_string.split('#')
        if split[1].indexOf('/') == -1
          gist_uuid = split[0]
      parts = gist_string.split('/')
      for sourceParserName of internal.sourceParsers
        sourceParser = internal.sourceParsers[sourceParserName]
        baseUrls = sourceParser.baseUrl
        if !Array.isArray(baseUrls)
          baseUrls = [ baseUrls ]
        j = 0
        while j < baseUrls.length
          baseUrl = baseUrls[j]
          if gist_string.indexOf(baseUrl) == 0
            result = sourceParser.parse(gist_string, parts, baseUrl)
            if 'error' of result and result.error
              errorMessage 'Error when parsing "' + gist_string + '" as a ' + sourceParserName + '.\n' + result.error
            else if 'id' of result
              return result.id
            return
          j++
      if gist_string.indexOf('?') != -1
        # in case a DocGist URL was pasted
        gist_uuid = gist_string.split('?').pop()
      else
        if gist_string.indexOf('://') != -1
          gist_uuid = gist_string
        else
          errorMessage 'Do not know how to parse "' + gist_string + '" as a DocGist source URL.'
    gist_uuid

  fetchGithubGist = (gist, success, error) ->
    if !VALID_GIST.test(gist)
      error 'The gist id is malformed: ' + gist
      return
    url = 'https://api.github.com/gists/' + gist.replace('/', '')
    $.ajax
      'url': url
      'success': (data) ->
        file = data.files[Object.keys(data.files)[0]]
        content = file.content
        link = data.html_url
        success content, link
        return
      'dataType': 'json'
      'error': (xhr, status, errorMessage) ->
        error errorMessage
        return
    return

  fetchGithubFile = (gist, success, error) ->
    gist = gist.substr(7)
    decoded = decodeURIComponent(gist)
    parts = decoded.split('/')
    branch = 'master'
    pathPartsIndex = 3
    if decoded.indexOf('/contents/') != -1
      window.location.href = '?github-' + encodeURIComponent(decoded.replace('/contents/', '//'))
      return
    if parts.length >= 4 and parts[3] == ''
      branch = parts[2]
      pathPartsIndex++
    url = 'https://api.github.com/repos/' + parts[0] + '/' + parts[1] + '/contents/' + parts.slice(pathPartsIndex).join('/')
    $.ajax
      'url': url
      'data': 'ref': branch
      'success': (data) ->
        content = Base64.decode(data.content)
        link = data.html_url
        imagesdir = 'https://raw.github.com/' + parts[0] + '/' + parts[1] + '/' + branch + '/' + data.path.substring(0, -data.name.length)
        success content, link, imagesdir
        return
      'dataType': 'json'
      'error': (xhr, status, errorMessage) ->
        error errorMessage
        return
    return

  fetchPublicDropboxFile = (id, success, error) ->
    id = id.substr(8)
    fetchDropboxFile id, success, error, DROPBOX_PUBLIC_BASE_URL
    return

  fetchPrivateDropboxFile = (id, success, error) ->
    id = id.substr(9)
    fetchDropboxFile id, success, error, DROPBOX_PRIVATE_API_BASE_URL
    return

  fetchDropboxFile = (id, success, error, baseUrl) ->
    url = baseUrl + decodeURIComponent(id)
    $.ajax
      'url': url
      'success': (data) ->
        success data, url
        return
      'dataType': 'text'
      'error': (xhr, status, errorMessage) ->
        error errorMessage
        return
    return

  fetchAnyUrl = (id, success, error) ->
    url = decodeURIComponent(id)
    $.ajax
      'url': url
      'success': (data) ->
        success data, url
        return
      'dataType': 'text'
      'error': (xhr, status, errorMessage) ->
        error errorMessage
        return
    return

  neo4jGistFetcher = (id, success, error) ->
    url = 'http://www.neo4j.org/api/graphgist?' + id
    $.ajax
      'url': url
      'success': (data, status, res) ->
        source = res.getResponseHeader('GraphGist-Source')
        success data, source or url
        return
      'dataType': 'text'
      'error': (xhr, status, errorMessage) ->
        error errorMessage
        return
    return

  useGithubGist = (minLength, index, parts) ->
    if parts.length < minLength
      return { 'error': 'No gist id in the URL.' }
    id = parts[index]
    if !VALID_GIST.test(id)
      return { 'error': 'No valid gist id in the url.' }
    { id: id }

  useGithubRepoParts = (spec, parts) ->
    { id: 'github-' + parts[3] + '/' + parts[4] + '//' + parts.slice(spec.path).join('/') }

  useRestOfTheUrl = (prefix, baseUrl, gist) ->
    if gist.length <= baseUrl.length
      return { 'error': 'Missing content in the URL.' }
    { 'id': prefix + gist.substr(baseUrl.length) }

  fetchLocalSnippet = (id, success, error) ->
    url = './gists/' + id + '.adoc'
    $.ajax
      'url': url
      'success': (data) ->
        link = 'https://github.com/neo4j-contrib/graphgist/tree/master/gists/' + id + '.adoc'
        success data, link
        return
      'dataType': 'text'
      'error': (xhr, status, errorMessage) ->
        error errorMessage
        return
    return

  errorMessage = (message, gist) ->
    messageText = undefined
    if gist
      messageText = 'Something went wrong fetching the GraphGist "' + gist + '":<p>' + message + '</p>'
    else
      messageText = '<p>' + message + '</p>'
    $content.html '<div class="alert alert-block alert-error"><h4>Error</h4>' + messageText + '</div>'
    return

  {
    getGistAndRenderPage: getGistAndRenderPage
    readSourceId: readSourceId
    preview_gist_from_url: preview_gist_from_url
    gist_uuid: gist_uuid
  }

'use strict'

