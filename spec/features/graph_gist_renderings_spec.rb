require 'rails_helper'

describe 'graph gist rendering', type: :feature, js: true do
  before { delete_db }

  use_vcr_cassette 'graph_gist_rendering', record: :new_episodes

  # Test GraphGist which exercises variosu features of GraphGists
  # Can also be used to visually inspect how well GraphGists are working
  let(:graph_gist) { create(:graph_gist, url: 'https://gist.github.com/cheerfulstoic/b905e1b8cb531a8c5620') }

  def table_data_following(text)
    page.evaluate_script("$('p:contains(#{text})').nextAll('.result-table').find('table').tableToJSON()")
  end

  it 'renders a graph gist' do
    visit '/graph_gists/' + graph_gist.id

    # Load javascript which converts HTML tables to JSON
    page.execute_script(Rails.root.join('spec/table_to_json.js').read)

    within('#gist-body') do
      # Gist loaded from source
      expect(page).to have_content 'GraphGist created to test the various features available to GraphGist rendering'

      # Images are displayed and converted to https when appropriate
      expect(page.find('img[src*="https://i.imgur.com/5giAsjq.png"]')).to be_a(Capybara::Node::Element)


      # Testing for a bug where table doesn't display when separated from it's query by a header
      expect(table_data_following('Table directly after a header:')).to eq ['text' => 'data after table']

      # Testing for a bug where table doesn't display when separated from it's query by a header
      text = 'Graph directly after a header:'
      graph_rendered = page.evaluate_script("$('p:contains(#{text})').nextAll('.visualization').find('svg').length === 1")
      expect(graph_rendered).to eq true


      # Table displays results from Neo4j server
      expect(table_data_following('Number of people:')).to eq ['count(a)' => '5']

      # Renders MathJax
      expect(page.find('.MathJax_Display')).to be_a(Capybara::Node::Element)
    end
  end
end
