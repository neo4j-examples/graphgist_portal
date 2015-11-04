require 'spec_helper'
require './lib/graph_gist_tools'

RSpec.describe GraphGistTools do
  use_vcr_cassette 'graph_gist_tools', record: :new_episodes

  describe '.raw_url_for' do
    subject { GraphGistTools.raw_url_for(url) }

    # GitHub Gists
    let_context url: 'https://gist.github.com/galliva/ca811daa580aee95bd07' do
      it { should eq 'https://gist.githubusercontent.com/galliva/ca811daa580aee95bd07/raw/aa11f84ec7cd02beeefd0bf892602cbf1ed09797/NoSQLGist' }
    end
    let_context url: 'https://gist.github.com/ca811daa580aee95bd07' do
      it { should eq 'https://gist.githubusercontent.com/galliva/ca811daa580aee95bd07/raw/aa11f84ec7cd02beeefd0bf892602cbf1ed09797/NoSQLGist' }
    end
    let_context url: 'https://gist.github.com/roquec/8176106' do
      it { should eq 'https://gist.githubusercontent.com/roquec/8176106/raw/872d8051788c08eeacb2e52c349e9c6bdf8e4803/medicine.adoc' }
    end
    let_context url: 'https://gist.github.com/roquec/8176106#with-anchor' do
      it { should eq 'https://gist.githubusercontent.com/roquec/8176106/raw/872d8051788c08eeacb2e52c349e9c6bdf8e4803/medicine.adoc' }
    end

    # Via gist.neo4j.org
    let_context url: 'http://gist.neo4j.org/?8176106' do
      it { should eq 'https://gist.githubusercontent.com/roquec/8176106/raw/872d8051788c08eeacb2e52c349e9c6bdf8e4803/medicine.adoc' }
    end
    let_context url: 'http://gist.neo4j.org/?8176106#with-anchor' do
      it { should eq 'https://gist.githubusercontent.com/roquec/8176106/raw/872d8051788c08eeacb2e52c349e9c6bdf8e4803/medicine.adoc' }
    end
    let_context url: 'https://gist.neo4j.org/?github-kbastani/gists//meta/TimeScaleEventMetaModel.adoc' do
      it { should eq 'https://raw.githubusercontent.com/kbastani/gists/master/meta/TimeScaleEventMetaModel.adoc' }
    end

    # Github repos
    let_context url: 'http://github.com/neo4j-examples/graphgists/blob/master/fraud/bank-fraud-detection.adoc' do
      it { should eq 'https://raw.githubusercontent.com/neo4j-examples/graphgists/master/fraud/bank-fraud-detection.adoc' }
    end

    let_context url: 'https://github.com/kvangundy/Slashco/blob/master/slashco.adoc' do
      it { should eq 'https://raw.githubusercontent.com/kvangundy/Slashco/master/slashco.adoc' }
    end

    # Dropbox
  end

  # This is the method which converts the special GraphGist URL syntax to URLs
  describe '.raw_url_for_graphgist_id' do
    subject { GraphGistTools.raw_url_for_graphgist_id(id) }
    let_context id: '8176106' do
      it { should eq 'https://gist.githubusercontent.com/roquec/8176106/raw/872d8051788c08eeacb2e52c349e9c6bdf8e4803/medicine.adoc' }
    end
    let_context id: 'github-kbastani/gists//meta/TimeScaleEventMetaModel.adoc' do
      it { should eq 'https://raw.githubusercontent.com/kbastani/gists/master/meta/TimeScaleEventMetaModel.adoc' }
    end
    # Encoded
    let_context id: 'github-neo4j-contrib%2Fgists%2F%2Fother%2FNetworkDataCenterManagement1.adoc' do
      it { should eq 'https://raw.githubusercontent.com/neo4j-contrib/gists/master/other/NetworkDataCenterManagement1.adoc' }
    end
  end
end

