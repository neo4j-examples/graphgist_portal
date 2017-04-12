#= require graph_starter/underscore
#= require jquery-ui.min
#= require d3.min
#= require jquery.dataTables
#= require cypher.datatable
#= require neod3
#= require neod3-visualization
#= require console
#= require gist
#= require dot
#= require graphgist
#= require base64
#= require mutate.min

#= require codemirror/runmode/runmode-standalone
#= require codemirror/runmode/colorize
#= require codemirror/mode/cypher

# Transform ASCIIdoc HTML output to match Semantic UI expectations
$('.sect1').addClass('ui container')
for code_element in $('code[class*="language-"]')
  classes = (e for e in code_element.classList when e.match(/^language-/))

  $(code_element).parent('pre').addClass(c) for c in classes

for element in $('div.paragraph')
  $(element).replaceWith($('<p>' + element.innerHTML + '</p>'));

DEFAULT_VERSION = '2.3'
CONSOLE_VERSIONS =
  '2.0.0-M06': 'http://neo4j-console-20m06.herokuapp.com/'
  '2.0.0-RC1': 'http://neo4j-console-20rc1.herokuapp.com/'
  '2.1': 'http://neo4j-console-21.herokuapp.com/'
  '2.2': 'http://neo4j-console-22.herokuapp.com/'
  '2.3': 'http://neo4j-console-23.herokuapp.com/'
  'local': 'http://localhost:8080/'
  '1.9': 'http://neo4j-console-19.herokuapp.com/'


GraphGistRenderer.renderContent()
