require "logstash/namespace"
require "logstash/outputs/base"

class LogStash::Outputs::Neo4j < LogStash::Outputs::Base

  config_name 'neo4j'

  # The path within your file system where the neo4j database is located
  config :path, :validate => :string, :required => true

  attr_reader :tree

  def register
    require "neo4j"
    require "logstash/outputs/timetree/timetree"
    if !Neo4j::Session.current
      @session = ::Neo4j::Session.open(:embedded_db, @path, :auto_commit => true)
      @session.start
    end
    @session = Neo4j::Session.current
    @tree = Neo4jrb::TimeTree.new(@session)
  end

  def receive(event)
    
    payload = event.to_hash
    timestamp = payload["@timestamp"].time
    @tree.add_event(timestamp, payload)
  end

  def teardown
    @session.shutdown
    @session.close
  end
end
