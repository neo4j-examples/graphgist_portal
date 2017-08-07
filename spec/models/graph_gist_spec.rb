require 'rails_helper'
require 'rspec/its'
require './lib/graph_gist_tools'

RSpec.describe GraphGistTools do
  use_vcr_cassette 'graph_gist', record: :new_episodes

  describe '#place_current_url' do
    before { Paperclip::Attachment.any_instance.stub(:save).and_return(true) }

    let(:graph_gist_id) { nil }
    let(:graph_gist_attributes) { {} }
    let(:graph_gist) { GraphGist.new(graph_gist_attributes.merge(url: url)) }

    subject do
      graph_gist.place_current_url
      graph_gist
    end

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

  describe '.httpsize_img_srces' do
    subject { GraphGist.httpsize_img_srces(html) }

    def self.it_should_transform_url_to_https(url)
      fail 'URL is https' if url.match(%r{https://})
      https_url = url.gsub(%r{^http://}, 'https://')

      let_context html: "<img src=\"#{url}\">" do
        it { should eq("<img src=\"#{https_url}\">") }
      end
    end

    it_should_transform_url_to_https('http://i.imgur.com/7sjySPv.jpg')
    it_should_transform_url_to_https('http://imgur.com/uNtRzl5.png')
    it_should_transform_url_to_https('http://i1303.photobucket.com/albums/ag146/vanaepi/domain_zps1e9c28ba.png')
    it_should_transform_url_to_https('http://s15.postimg.org/gtp6h02ff/rel_detail.png')
    it_should_transform_url_to_https('http://raw.github.com/neo4j-contrib/gists/master/other/images/datacenter-management-1.PNG')
    it_should_transform_url_to_https('http://raw.githubusercontent.com/rkuo/GraphGist/master/sfbaymap/images/Screen%20Shot%202014-08-29%20at%202.28.39%20PM%20sfbaymodel3trainto.png')
    it_should_transform_url_to_https('http://media.giphy.com/media/ColbXXtLhOz0k/giphy.gif')
    it_should_transform_url_to_https('http://4.bp.blogspot.com/-DRBXuNiBSYc/UGtkY6i5SJI/AAAAAAAAPTc/87jFEiw40pg/s486/link-blogger-faceboook-twitter-gplus-youtube-pinterest.png')

    it_should_transform_url_to_https('http://dl.dropboxusercontent.com/u/67572426/img/pearson.png')
    it_should_transform_url_to_https('http://www.dropbox.com/s/chrt0ikwf2ohx4a/egfr-erk-pathway.png?dl=1')
    # it_should_transform_url_to_https('http://docs.google.com/drawings/d/1Wiue3RRsqenQm60trFDZgC3leeFzrFEGnlAigJnSXjg/pub?w=960&h=720')

    let_context html: "<img src=\"http://some.random.com/test.png\">" do
      it { should eq("<img src=\"http://some.random.com/test.png\">") }
    end

    # rubocop:disable Metrics/LineLength
    let_context html: "<img src=\"http://yuml.me/diagram/scruffy/class/[Speaker%7C+serial+;+twitter+]-SPEAKS_AT-0..*%3E[Event%7C+serial+],[Event]-AT_VENUE%3E[Venue%7C+serial+].png\">" do
      it { should eq("<img src=\"http://yuml.me/diagram/scruffy/class/%5BSpeaker%7C+serial+;+twitter+%5D-SPEAKS_AT-0..*%3E%5BEvent%7C+serial+%5D,%5BEvent%5D-AT_VENUE%3E%5BVenue%7C+serial+%5D.png\">") }
    end
    # rubocop:enable Metrics/LineLength

    let_context html: "<img foo=\"bar\">" do
      it { should eq("<img foo=\"bar\">") }
    end
  end
end
