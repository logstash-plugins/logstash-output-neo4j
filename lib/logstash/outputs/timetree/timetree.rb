require "neo4j"
require "logstash/outputs/timetree/model"

module Neo4jrb
  class TimeTree

    attr_reader :root

    def initialize(session)
      @session = session
      @root    = ::TimeTree::Root.first || create_node(::TimeTree::Root)
    end

    def add_event(ts, event)
      Neo4j::Transaction.run do
        start = refresh_tree(ts)
        append(start, event)
      end
    end

    def events_between(start_time, end_time)
      raise Exception.new("Not implemented yet!")
    end

    def events_from(start_time)
      raise Exception.new("Not implemented yet!")
    end

    def events_at(start_time)
      query = <<-QUERY
            MATCH (a:`TimeTree::Year`{value:#{start_time.year}})-[:`child`]->(b:`TimeTree::Month`{value:#{start_time.month}})-[:`child`]->(d:`TimeTree::Day`{value:#{start_time.day}})
            WITH d MATCH (e:`TimeTree::Event`)<-[:`child`]-(d)
            RETURN e
      QUERY
      run_query(query)
    end

    def refresh_tree(ts)
      year  = append_element(@root,  ::TimeTree::Year, ts.year)
      month = append_element(year,  ::TimeTree::Month, ts.month)
      append_element(month, ::TimeTree::Day, ts.day)
    end

    def append(start, event)
      event = create_node(::TimeTree::Event, {:message => event, :created_at => Time.now})
      ::TimeTree::Child.create(:from_node => start, :to_node => event)
    end

    def append_element(root, clazz, value)
      childs = has_child(root)
      if !childs.empty?
        selected = childs.select { |e| e.props[:value] == value }
        return selected.first if !selected.empty?
      end
      node = find_or_create(clazz, root, {:value => value})
      set_edge_to_first_node(root, node) if childs.empty?
      ::TimeTree::Child.create(:from_node => root, :to_node => node)
      set_edge_to_last_node(root, node)
      node
    end

    def find_or_create(clazz, root, criteria)
      nodes = clazz.where(criteria).map do |n|
         n.nodes(:dir => :incoming, :type => :child).select do |p|
           p.class == root.class && (!root.is_a?(::TimeTree::Root) && p.props[:value] == root.props[:value])
         end
      end.flatten
      ( nodes.empty? ? clazz.create(criteria) : nodes.first )
    end

    def set_edge_to_first_node(root, node)
      ::TimeTree::First.create(:from_node => root, :to_node => node)
    end

    def set_edge_to_last_node(root, node)
      Neo4j::Transaction.run do
        ::TimeTree::Last.create(:from_node => root, :to_node => node)
      end
      rels = root.rel(:dir => :outgoing, :type => :last)
      rels.del
    end

    def create_node(clazz, props={})
      clazz.create(props)
    end

    def has_child(base)
      has(base, :outgoing)
    end

    def has_parent(base, value)
      has(base, :incoming)
    end

    def has(base, dir)
      base.nodes(:dir => dir, :type => :child)
    end

    private
    def run_query(query)
      resultset = Neo4j::Session.query(query)
      resultset.map(&:e).to_a
    end

  end
end
