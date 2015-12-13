require 'rails_helper'
require './lib/graph_gist_tools'

RSpec.describe GraphGistTools do
  use_vcr_cassette 'graph_gist', record: :new_episodes

  describe '#place_current_url' do
    let(:graph_gist_id) { nil }
    let(:graph_gist) { GraphGist.new(url: url) }
    before { graph_gist.place_current_url }

    subject { graph_gist }

    let_context url: 'https://dl.dropboxusercontent.com/s/vhtxfibv7ycstrv/BankFraudDetection.adoc.txt?dl=0' do
      its(:raw_url) { should eq 'https://dl.dropboxusercontent.com/s/vhtxfibv7ycstrv/BankFraudDetection.adoc.txt?dl=0' }
      its(:asciidoc) { should match(/This interactive Neo4j graph tutorial covers bank fraud detection scenarios/) }
    end

    let_context url: 'https://dl.dropboxusercontent.com/u/14493611' do
      its(:raw_url) { should be_nil }
    end
  end
end
