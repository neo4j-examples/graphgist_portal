require 'spec_helper'
require './lib/graph_gist_tools'

RSpec.describe GraphGistTools do
  use_vcr_cassette 'graph_gist_tools', record: :new_episodes

  describe '.raw_url_for' do
    subject { GraphGistTools.raw_url_for(url) }

    describe 'error cases' do
      let_context url: 'not a url' do
        it { should be_nil }
      end

      let_context url: 'http://naodeonaedinaoedinodoaeu.oue/foo.adoc' do
        it { should be_nil }
      end
    end

    describe 'GitHub Gists' do
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
      let_context url: 'https://gist.github.com/patbaumgartner/8139605' do
        it { should eq 'https://gist.githubusercontent.com/patbaumgartner/8139605/raw/c5a8c8476f9b68508ed2a15c0603ee72fc8cd189/Single%20Malt%20Scotch%20Whisky%20GraphGist.adoc' }
      end

      let_context url: 'https://gist.github.com/cheerfulstoic/ba9e1c2225aa5259b10e' do
        it { should eq 'https://gist.githubusercontent.com/cheerfulstoic/ba9e1c2225aa5259b10e/raw/d456edc4e351da09f6b46a160b0cff3e4484a52e/graph_gist_template.adoc' }
      end
      let_context url: 'https://gist.github.com/cheerfulstoic/ba9e1c2225aa5259b10e/edit' do
        it { should eq 'https://gist.githubusercontent.com/cheerfulstoic/ba9e1c2225aa5259b10e/raw/d456edc4e351da09f6b46a160b0cff3e4484a52e/graph_gist_template.adoc' }
      end

      describe 'Revisions' do
        let_context url: 'https://gist.github.com/dhimmel/f69730d8bdfb880c15ed/a6d42b952462aedad14003d6c0422b586a7a3c14' do
          it { should eq 'https://gist.githubusercontent.com/dhimmel/f69730d8bdfb880c15ed/raw/272c4985cea9bfe86f88da84d79f893f899bb02c/cypher-edge-swap.adoc' }
        end
      end
    end

    describe 'gist.neo4j.org' do
      let_context url: 'http://gist.neo4j.org/?8176106' do
        it { should eq 'https://gist.githubusercontent.com/roquec/8176106/raw/872d8051788c08eeacb2e52c349e9c6bdf8e4803/medicine.adoc' }
      end
      let_context url: 'http://gist.neo4j.org/?8176106#with-anchor' do
        it { should eq 'https://gist.githubusercontent.com/roquec/8176106/raw/872d8051788c08eeacb2e52c349e9c6bdf8e4803/medicine.adoc' }
      end
      let_context url: 'https://gist.neo4j.org/?github-kbastani/gists//meta/TimeScaleEventMetaModel.adoc' do
        it { should eq 'https://raw.githubusercontent.com/kbastani/gists/master/meta/TimeScaleEventMetaModel.adoc' }
      end
    end

    describe 'graphgist.neo4j.com' do
      let_context url: 'http://graphgist.neo4j.com/#!/gists/8176106' do
        it { should eq 'https://gist.githubusercontent.com/roquec/8176106/raw/872d8051788c08eeacb2e52c349e9c6bdf8e4803/medicine.adoc' }
      end

      # IDs of this form are internal to the node.js app DB.  Could probably query for the raw URL, but punting for now
      let_context url: 'http://graphgist.neo4j.com/#!/gists/1428842b2170702400451777c2bc813f' do
        it { should be_nil }
      end
    end

    # Github repos
    let_context url: 'http://github.com/neo4j-examples/graphgists/blob/master/fraud/bank-fraud-detection.adoc' do
      it { should eq 'https://raw.githubusercontent.com/neo4j-examples/graphgists/master/fraud/bank-fraud-detection.adoc' }
    end

    let_context url: 'https://github.com/kvangundy/Slashco/blob/master/slashco.adoc' do
      it { should eq 'https://raw.githubusercontent.com/kvangundy/Slashco/master/slashco.adoc' }
    end

    describe 'Dropbox' do
      let_context url: 'https://www.dropbox.com/s/81fka14d5hyg378/gistfile1.txt?dl=0' do
        it { should eq 'https://www.dropbox.com/s/81fka14d5hyg378/gistfile1.txt?dl=1' }
      end

      let_context url: 'https://www.dropbox.com/s/81fka14d5hyg378/gistfile1.txt' do
        it { should eq 'https://www.dropbox.com/s/81fka14d5hyg378/gistfile1.txt?dl=1' }
      end

      let_context url: 'https://dropbox.com/s/81fka14d5hyg378/gistfile1.txt?dl=0' do
        it { should eq 'https://www.dropbox.com/s/81fka14d5hyg378/gistfile1.txt?dl=1' }
      end

      let_context url: 'http://www.dropbox.com/s/81fka14d5hyg378/gistfile1.txt?dl=0' do
        it { should eq 'https://www.dropbox.com/s/81fka14d5hyg378/gistfile1.txt?dl=1' }
      end

      let_context url: 'https://www.dropbox.com/s/81fka14d5hyg378/gistfile1.txt?dl=1' do
        it { should eq 'https://www.dropbox.com/s/81fka14d5hyg378/gistfile1.txt?dl=1' }
      end

      # Bad URL
      let_context url: 'https://dl.dropboxusercontent.com/u/14493611' do
        it { should be_nil }
      end
    end

    describe 'pastebin' do
      let_context url: 'http://pastebin.com/AFmNzecE' do
        it { should eq 'http://pastebin.com/raw.php?i=AFmNzecE' }
      end

      let_context url: 'https://pastebin.com/AFmNzecE' do
        it { should eq 'http://pastebin.com/raw.php?i=AFmNzecE' }
      end

      let_context url: 'https://www.pastebin.com/AFmNzecE' do
        it { should eq 'http://pastebin.com/raw.php?i=AFmNzecE' }
      end
    end

    describe 'etherpad' do
      let_context url: 'https://public.etherpad-mozilla.org/p/aouoeuoeu' do
        it { should eq 'https://public.etherpad-mozilla.org/p/aouoeuoeu/export/txt' }
      end

      let_context url: 'http://beta.etherpad.org/p/IudqLHvuRj' do
        it { should eq 'http://beta.etherpad.org/p/IudqLHvuRj/export/txt' }
      end
    end

    describe 'Google docs' do
      let_context url: 'https://docs.google.com/document/u/0/export?format=txt&id=1mWWQ8bp6-q_D4SOpcfhmQ4fKaNsfQDtx5zxTu3D2uIw&token=AC4w5VhoYYXF6XPJLJfjfIufyeHlai6D-g%3A1447325752412' do
        it { should eq 'https://docs.google.com/document/u/0/export?format=txt&id=1mWWQ8bp6-q_D4SOpcfhmQ4fKaNsfQDtx5zxTu3D2uIw&token=AC4w5VhoYYXF6XPJLJfjfIufyeHlai6D-g%3A1447325752412' }
      end

      let_context url: 'https://docs.google.com/document/d/1mWWQ8bp6-q_D4SOpcfhmQ4fKaNsfQDtx5zxTu3D2uIw/edit' do
        it { should eq 'https://docs.google.com/document/u/0/export?format=txt&id=1mWWQ8bp6-q_D4SOpcfhmQ4fKaNsfQDtx5zxTu3D2uIw' }
      end

      let_context url: 'https://docs.google.com/document/d/1mWWQ8bp6-q_D4SOpcfhmQ4fKaNsfQDtx5zxTu3D2uIw' do
        it { should eq 'https://docs.google.com/document/u/0/export?format=txt&id=1mWWQ8bp6-q_D4SOpcfhmQ4fKaNsfQDtx5zxTu3D2uIw' }
      end
    end

    describe 'non-text responses' do
      let_context url: 'https://gricker.files.wordpress.com/2015/02/graph.png' do
        it { should be_nil }
      end
    end
  end

  # This is the method which converts the special GraphGist URL syntax to URLs
  describe '.raw_url_for_graphgist_id' do
    subject { GraphGistTools.raw_url_for_graphgist_id(id) }

    describe 'GitHub gists' do
      let_context id: '8176106' do
        it { should eq 'https://gist.githubusercontent.com/roquec/8176106/raw/872d8051788c08eeacb2e52c349e9c6bdf8e4803/medicine.adoc' }
      end
      let_context id: '6009066' do
        it { should eq 'https://gist.githubusercontent.com/peterneubauer/6009066/raw/b0dd549f6299b4a5dcc9e32982996f33b012c415/T-Graph.adoc' }
      end
      let_context id: 'ba9e1c2225aa5259b10e' do
        it { should eq 'https://gist.githubusercontent.com/cheerfulstoic/ba9e1c2225aa5259b10e/raw/d456edc4e351da09f6b46a160b0cff3e4484a52e/graph_gist_template.adoc' }
      end

      # More than one file in a Gist
      let_context id: 'd788e117129c3730a042' do
        it 'should raise an exception' do
          expect { subject }.to raise_error GraphGistTools::InvalidGraphGistIDError, /Gist has more than one file/
        end
      end
    end

    describe 'GitHub files' do
      let_context id: 'github-kbastani/gists//meta/TimeScaleEventMetaModel.adoc' do
        it { should eq 'https://raw.githubusercontent.com/kbastani/gists/master/meta/TimeScaleEventMetaModel.adoc' }
      end
      let_context id: 'github-whatSocks/jobSNV//socialNetworks.adoc' do
        it { should eq 'https://raw.githubusercontent.com/whatSocks/jobSNV/master/socialNetworks.adoc' }
      end
      # Encoded
      let_context id: 'github-neo4j-contrib%2Fgists%2F%2Fother%2FNetworkDataCenterManagement1.adoc' do
        it { should eq 'https://raw.githubusercontent.com/neo4j-contrib/gists/master/other/NetworkDataCenterManagement1.adoc' }
      end

      # blobs
      let_context id: 'github-kbastani/gists//meta/TimeScaleEventMetaModel.adoc' do
        it { should eq 'https://raw.githubusercontent.com/kbastani/gists/master/meta/TimeScaleEventMetaModel.adoc' }
      end

      # Other
      # Occurred in Rollbar
      let_context id: 'github-jotomo' do
        it { should be_nil }
      end
    end

    describe 'Dropbox' do
      let_context id: 'dropboxs-vhtxfibv7ycstrv/BankFraudDetection.adoc.txt?dl=0' do
        it { should eq 'https://dl.dropboxusercontent.com/s/vhtxfibv7ycstrv/BankFraudDetection.adoc.txt?dl=0' }
      end

      # Invalid ID
      let_context id: 'dropbox-14493611' do
        it { should eq 'https://dl.dropboxusercontent.com/u/14493611' } # Invalid URL, tested above
      end
    end

    describe 'copy.com' do
      # Public files
      let_context id: 'copy-7MuhBZKFDsCIPNLp' do
        it { should eq 'https://copy.com/7MuhBZKFDsCIPNLp?download=1' }
      end

      # Direct files
      let_context id: 'copy-7MuhBZKFDsCIPNLp/analysis.txt' do
        it { should eq 'https://copy.com/7MuhBZKFDsCIPNLp/analysis.txt?download=1' }
      end
    end

    describe 'Raw URLs' do
      let_context id: 'https%3A%2F%2Fgist.githubusercontent.com%2Frvanbruggen%2Fc82d0a68d32cf3067706%2Fraw%2Fe05fa4ff92c1822acac87593f058a06f0798f141%2FMiddle%2520East%2520GraphGist.adoc' do
        it { should eq 'https://gist.githubusercontent.com/rvanbruggen/c82d0a68d32cf3067706/raw/e05fa4ff92c1822acac87593f058a06f0798f141/Middle%20East%20GraphGist.adoc' }
      end

      let_context id: 'https://gist.githubusercontent.com/rvanbruggen/c82d0a68d32cf3067706/raw/e05fa4ff92c1822acac87593f058a06f0798f141/Middle%20East%20GraphGist.adoc' do
        it { should eq 'https://gist.githubusercontent.com/rvanbruggen/c82d0a68d32cf3067706/raw/e05fa4ff92c1822acac87593f058a06f0798f141/Middle%20East%20GraphGist.adoc' }
      end
    end
  end
end
