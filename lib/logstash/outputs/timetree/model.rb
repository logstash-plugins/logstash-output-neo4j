module TimeTree

  class Root
    include Neo4j::ActiveNode
  end

  class Year
    include Neo4j::ActiveNode
    property :value, index: :exact
  end

  class Month
    include Neo4j::ActiveNode
    property :value, index: :exact
  end

  class Day
    include Neo4j::ActiveNode
    property :value, index: :exact
  end

  class Event
    include Neo4j::ActiveNode

    property :message
    serialize :message
    property :created_at
  end

  class Child
    include Neo4j::ActiveRel
    from_class :any
    to_class   :any
    type 'child'
  end

  class First
    include Neo4j::ActiveRel
    from_class :any
    to_class   :any
    type 'first'
  end

  class Last
    include Neo4j::ActiveRel
    from_class :any
    to_class   :any
    type 'last'
  end

  class Next
    include Neo4j::ActiveRel
    from_class :any
    to_class   :any
    type 'next'
  end

end
