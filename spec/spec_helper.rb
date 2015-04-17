require 'logstash/outputs/neo4j'

def load_fixture(name)
  IO.read("spec/fixtures/#{name}")
end

RSpec.configure do |config|

  config.before(:suite) do
    FileUtils.rm_rf '/tmp/db'
    session = Neo4j::Session.open(:embedded_db, '/tmp/db', auto_commit: true)
    session.start
  end

  config.after(:suite) do
    Neo4j::Session.current.shutdown
  end

end

def to_arr(root)
  Neo4j::Transaction.run do
    session.graph_db.get_all_nodes.to_a.map { |m| "#{m.props[:_classname]}##{m.props[:value]||'NaN'}" }
  end
end

def has_child(source_clazz, source_value, target_clazz, target_value)
  source_clazz.where({:value => source_value}).map do |n|
    n.nodes(dir: :outgoing, :type => :child).select do |m|
      m.is_a?(target_clazz) && (!m.is_a?(::TimeTree::Root) && m.props[:value] == target_value)
    end
  end.flatten
end

