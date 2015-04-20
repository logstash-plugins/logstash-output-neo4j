require 'spec_helper'
require "logstash/plugin"
require "logstash/json"

describe "outputs/neo4j" do

  context "registration" do

    let(:output) { LogStash::Plugin.lookup("output", "neo4j").new("path" => "/tmp/db") }

    it "should register" do
      expect { output.register }.to_not raise_error
    end

    it "should teardown" do
      output.register
      expect { output.teardown }.to_not raise_error
    end
  end

  context "operation" do

    let(:output) { LogStash::Outputs::Neo4j.new("path" => "/tmp/db") }
    let(:props)  { { :name => 'plugin.operation', :product => 'logstash-output-neo4j' } }
    let(:event)  { LogStash::Event.new(props) }
    let(:tree)   { output.tree }

    before do
      output.register
    end

    it "receive a message" do
      output.receive(event)
      events = tree.events_at(event.to_hash["@timestamp"].time)
      expect(events.count).to eq(1)
    end

  end

end
