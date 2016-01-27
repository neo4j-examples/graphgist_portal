require 'rails_helper'
require './lib/graph_gist_tools'

RSpec.describe GraphGistTools do
  use_vcr_cassette 'graph_gist', record: :new_episodes

  describe '#place_current_url' do
    before { Paperclip::Attachment.any_instance.stub(:save).and_return(true) }

    let(:graph_gist_id) { nil }
    let(:graph_gist_attributes) { {} }
    let(:graph_gist) { GraphGist.new(graph_gist_attributes.merge(url: url)) }

    subject { graph_gist.place_current_url; graph_gist }

    let_context url: 'https://dl.dropboxusercontent.com/s/vhtxfibv7ycstrv/BankFraudDetection.adoc.txt?dl=0' do
      its(:raw_url) { should eq 'https://dl.dropboxusercontent.com/s/vhtxfibv7ycstrv/BankFraudDetection.adoc.txt?dl=0' }
      its(:asciidoc) { should match(/This interactive Neo4j graph tutorial covers bank fraud detection scenarios/) }
    end

    let_context url: 'https://dl.dropboxusercontent.com/u/14493611' do
      its(:raw_url) { should be_nil }
    end

    let_context url: 'https://gist.github.com/cheerfulstoic/449393e2d1b6806112f1' do
      describe 'title' do
        its(:title) { should eq('The best GraphGist evahh!') }

        let_context graph_gist_attributes: {title: 'Already exists'} do
          its(:title) { should eq('Already exists') }
        end
      end

      describe 'image' do
        its('image.source.url') { should match(/s3.amazonaws.com/) }
        its('image.source.original_filename') { should match('RAVQA12.jpg') }
        its('image.original_url') { should eq('http://i.imgur.com/RAVQA12.jpg') }
      end
    end

    let_context url: 'https://gist.github.com/cheerfulstoic/50e8990cb2b5d625c2f5' do
      subject { -> { graph_gist.place_current_url } }
      it { should raise_error(TypeError, 'no implicit conversion of URI::Generic into String') }
    end
  end
end
