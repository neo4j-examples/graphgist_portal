require 'rails_helper'

RSpec.describe QueryController, type: :controller do
  before { delete_db }
  before(:each) { Rails.cache.clear }

  use_vcr_cassette 'query_controller', record: :new_episodes

  let(:expected_host) { 'neo4j-console-31.herokuapp.com' }
  let(:original_secure_random_uuid_method) { SecureRandom.method(:uuid) }

  let(:default_connection) do
    double(:default_connection).tap do |default_connection|
      allow(Faraday).to receive(:default_connection)
        .and_return(default_connection)
    end
  end

  let(:default_faraday_result) { double('default faraday result', env: {}, body: 'OK', status: 200) }

  describe 'graph_gist_query_session_id' do
    it 'should return a SecureRandom.uuid and make a request to the console app' do
      expect(SecureRandom).to receive(:uuid).exactly(1).times.and_return('the-id')
      expect(default_connection).to receive(:post)
        .with("http://#{expected_host}/console/init", '{"init":"none"}', 'X-Session': 'the-id', 'Cookie': '')
        .exactly(1).times.and_return(default_faraday_result)

      get(:graph_gist_query_session_id)
    end
  end

  describe 'graph_gist_query' do
    let(:graph_gist) { create(:graph_gist, cached: true) }
    let(:neo4j_version_param) { '3.1' }

    def request_graphgist_session_id # rubocop:disable Metrics/AbcSize
      uuid = original_secure_random_uuid_method.call
      allow(SecureRandom).to receive(:uuid).and_return(uuid)

      expect(default_connection).to receive(:post)
        .with("http://#{expected_host}/console/init", '{"init":"none"}', 'X-Session': uuid, 'Cookie': '')
        .exactly(1).times.and_return(default_faraday_result)

      get(:graph_gist_query_session_id)
      response.body
    end

    def make_query_request(cypher, gist_load_session)
      get(:graph_gist_query,
          graphgist_id: graph_gist.id,
          gist_load_session: gist_load_session,
          neo4j_version: neo4j_version_param,
          cypher: cypher)
    end

    let(:session_a_id) { request_graphgist_session_id }
    let(:session_b_id) { request_graphgist_session_id }

    let_context neo4j_version_param: '2.1' do
      it 'uses the correct URL' do
        expect(default_connection).to receive(:post)
          .with('http://neo4j-console-21.herokuapp.com/console/cypher', "CREATE (n:Person {name: 'Sally'})", 'X-Session': session_a_id, 'Cookie': '')
          .and_return(default_faraday_result)
          .exactly(1).times

        make_query_request("CREATE (n:Person {name: 'Sally'})", session_a_id)
        expect(response.body).to eq('OK')
      end
    end

    it 'raises an error when session is not from the server' do
      expect do
        make_query_request("CREATE (n:Person {name: 'Sally'})", '1234')
      end.to raise_error KeyError, 'key not found: "1234"'
    end

    # it 'caches the the inital query' do
    #   expect(default_connection).to receive(:post)
    #     .with('http://neo4j-console-31.herokuapp.com/console/cypher', "CREATE (n:Person {name: 'Sally'})", 'X-Session': session_a_id, 'Cookie': '')
    #     .and_return(default_faraday_result)
    #     .exactly(1).times

    #   make_query_request("CREATE (n:Person {name: 'Sally'})", session_a_id)
    #   expect(response.body).to eq('OK')

    #   make_query_request("CREATE (n:Person {name: 'Sally'})", session_b_id)
    #   expect(response.body).to eq('OK')
    # end

    # it 'caches two queries' do
    #   expect(default_connection).to receive(:post)
    #     .with('http://neo4j-console-31.herokuapp.com/console/cypher', "CREATE (n:Person {name: 'Sally'})", 'X-Session': session_a_id, 'Cookie': '')
    #     .and_return(default_faraday_result)
    #     .exactly(1).times

    #   expect(default_connection).to receive(:post)
    #     .with('http://neo4j-console-31.herokuapp.com/console/cypher', 'MATCH (n:Person) RETURN n', 'X-Session': session_a_id, 'Cookie': '')
    #     .and_return(default_faraday_result)
    #     .exactly(1).times


    #   make_query_request("CREATE (n:Person {name: 'Sally'})", session_a_id)
    #   expect(response.body).to eq('OK')
    #   make_query_request("CREATE (n:Person {name: 'Sally'})", session_b_id)
    #   expect(response.body).to eq('OK')

    #   make_query_request('MATCH (n:Person) RETURN n', session_a_id)
    #   expect(response.body).to eq('OK')
    #   make_query_request('MATCH (n:Person) RETURN n', session_b_id)
    #   expect(response.body).to eq('OK')
    # end

    # it 'does not cache if earlier queries change' do
    #   expect(default_connection).to receive(:post)
    #     .with('http://neo4j-console-31.herokuapp.com/console/cypher', "CREATE (n:Person {name: 'Sally'})", 'X-Session': session_a_id, 'Cookie': '')
    #     .and_return(default_faraday_result)
    #     .exactly(1).times

    #   expect(default_connection).to receive(:post)
    #     .with('http://neo4j-console-31.herokuapp.com/console/cypher', "CREATE (n:Person {name: 'sally'})", 'X-Session': session_b_id, 'Cookie': '')
    #     .and_return(default_faraday_result)
    #     .exactly(1).times

    #   expect(default_connection).to receive(:post)
    #     .with('http://neo4j-console-31.herokuapp.com/console/cypher', 'MATCH (n:Person) RETURN n', 'X-Session': session_a_id, 'Cookie': '')
    #     .and_return(default_faraday_result)
    #     .exactly(1).times

    #   expect(default_connection).to receive(:post)
    #     .with('http://neo4j-console-31.herokuapp.com/console/cypher', 'MATCH (n:Person) RETURN n', 'X-Session': session_b_id, 'Cookie': '')
    #     .and_return(default_faraday_result)
    #     .exactly(1).times

    #   make_query_request("CREATE (n:Person {name: 'Sally'})", session_a_id)
    #   expect(response.body).to eq('OK')
    #   make_query_request("CREATE (n:Person {name: 'sally'})", session_b_id)
    #   expect(response.body).to eq('OK')

    #   make_query_request('MATCH (n:Person) RETURN n', session_a_id)
    #   expect(response.body).to eq('OK')
    #   make_query_request('MATCH (n:Person) RETURN n', session_b_id)
    #   expect(response.body).to eq('OK')
    # end
  end
end
