require 'rails_helper'

describe 'graph gist rendering', type: :feature, js: true, sauce: ENV['CI'] do
  before { delete_db }

  use_vcr_cassette 'graph_gist_rendering', record: :new_episodes

  # Test GraphGist which exercises variosu features of GraphGists
  # Can also be used to visually inspect how well GraphGists are working
  graph_gist = GraphGist.create(status: 'live', asciidoc: File.read("./spec/features/acid_test.adoc"))

  def table_data_following(text)
    page.evaluate_script("$('p:contains(#{text})').nextAll('.result-table').find('table').tableToJSON()")
  end

  it 'renders a graph gist' do
    graph_gist.save

    visit '/graph_gists/' + graph_gist.id

    within('#gist-body') do
      # ASCIIdoc formatting checks
      expect(page).to have_css('h1', text: 'Level 1 Header')
      expect(page).to have_css('h2', text: 'Level 2 Header')
      expect(page).to have_css('h3', text: 'Level 3 Header')

      expect(page).to have_css('em', text: 'italic')
      expect(page).to have_css('strong', text: 'bold')
      expect(page).to have_css('code', text: 'Monospace')
      expect(page).to have_link('Link Text', href: 'http://example.org')

      # Gist loaded from source
      expect(page).to have_content 'GraphGist created to test the various features available to GraphGist rendering'

      # Images are displayed and converted to https when appropriate
      expect(page.find('img[src*="https://i.imgur.com/5giAsjq.png"]')).to be_a(Capybara::Node::Element)

      wait_for_ajax

      text = 'Graph result'
      node_count = page.evaluate_script("$($('p:contains(#{text})').nextAll('.visualization')[0]).find('svg g.node').length")
      expect(node_count).to eq(2)

      text = 'Full graph'
      node_count = page.evaluate_script("$($('p:contains(#{text})').nextAll('.visualization')[0]).find('svg g.node').length")
      expect(node_count).to eq(6)

      # Load javascript which converts HTML tables to JSON
      page.execute_script(Rails.root.join('spec/table_to_json.js').read)

      # Table displays results from Neo4j server
      expect(table_data_following('Number of people:')).to eq ['count(a)' => '5']


      # Testing for a bug where table doesn't display when separated from it's query by a header
      expect(table_data_following('Table directly after a header:')).to eq ['text' => 'table after header']

      # Testing for a bug where table doesn't display when separated from it's query by a header
      text = 'Graph directly after a header:'
      rendered = page.evaluate_script("$('p:contains(#{text})').nextAll('.visualization').find('svg').length === 1")
      expect(rendered).to eq true

      #
      # Colorization
      text = 'Should be colorized'
      fill = page.evaluate_script("$('p:contains(#{text})').nextAll('.visualization').find('svg g.node circle')[0].attributes.fill.value")
      expect(fill.upcase).to eq('#54A835')
      stroke = page.evaluate_script("$('p:contains(#{text})').nextAll('.visualization').find('svg g.node circle')[0].attributes.stroke.value")
      expect(stroke.upcase).to eq('#1078B5')
      text_fill = page.evaluate_script("$('p:contains(#{text})').nextAll('.visualization').find('svg g.node text')[0].attributes.fill.value")
      expect(text_fill).to eq('white')

      # Renders MathJax
      expect(page.find('.MathJax_Display', :visible => false)).to be_a(Capybara::Node::Element)

      # Error reporting
      text = 'errors stop execution of queries'
      error_text = page.evaluate_script("$('p:contains(#{text})').nextAll('.listingblock').find('.query-message').text()")
      expect(error_text).to match('Unexpected end of input')
    end
  end
end
