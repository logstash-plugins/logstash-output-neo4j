require 'spec_helper'

describe 'Neo4jrb::Timetree' do

  let(:session) { Neo4j::Session.current }
  let(:tree)    { Neo4jrb::TimeTree.new(session) }

  it "starts without errors" do
    expect(session.running?).to be_true
  end

  context "add an event" do

    let(:timestamp) { Time.new(2015, 1, 2) }
    let(:event)     { { :name => 'load', :product => 'ads' } }

    it "updates a new time tree" do
      tree.add_event(timestamp, event)
      expect(to_arr(tree.root)).to include("TimeTree::Root#NaN", "TimeTree::Year#2015", "TimeTree::Month#1", "TimeTree::Day#2")
    end

    it "add a second event in a different month without affecting the structure" do
      time = Time.new(2015, 2, 2)
      tree.add_event(time, event)
      expect(to_arr(tree.root)).to include("TimeTree::Root#NaN", "TimeTree::Year#2015", "TimeTree::Month#1", "TimeTree::Day#2",
                                           "TimeTree::Month#2", "TimeTree::Day#2")
    end

    it "add an event pending using an existing months and year" do
      time = Time.new(2015, 1, 3)
      tree.add_event(time, event)
      expect(has_child(TimeTree::Month, 1, TimeTree::Day, 3)).to_not be_empty
    end

  end

  context "fetching events by time" do

    let(:event)      { { :name => 'fetching_event', :product => 'logstash-output-neo4j' } }
    let(:new_event)  { { :name => 'another_fetching_event', :product => 'logstash-output-neo4j' } }

    it "has an event added at the end of a given day" do
      timestamp = Time.new(2015, 12, 26)
      tree.add_event(timestamp, event)
      event = tree.events_at(timestamp).first
      expect(event.props).to include(:message=>{"name"=>"fetching_event", "product"=>"logstash-output-neo4j"})
    end

    it "can fetch more than one events together" do
      timestamp = Time.new(2015, 12, 25)
      [event, new_event].each do |payload|
        tree.add_event(timestamp, payload)
      end
      events = tree.events_at(timestamp)
      expect(events.count).to eq(2)
    end

  end
end
