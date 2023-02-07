public extension Graph
{
    init(values: some Sequence<NodeValue>)
        where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        self.init(idValuePairs: values.map { ($0.id, $0) })
    }
    
    /**
     Uses the `NodeValue.ID` of a value as the ``GraphNode/id`` for its corresponding node
     */
    init(values: some Sequence<NodeValue>,
         edges: some Sequence<(NodeID, NodeID)>)
        where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        self.init(idValuePairs: values.map { ($0.id, $0) },
                  edges: edges)
    }
    
    init(values: some Sequence<NodeValue>,
         edgeTuples: some Sequence<(NodeID, NodeID)>)
        where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        self.init(idValuePairs: values.map { ($0.id, $0) },
                  edges: edgeTuples)
    }
    
    /**
     Uses the `NodeValue.ID` of a value as the ``GraphNode/id`` for its corresponding node
     */
    init(values: some Sequence<NodeValue>,
         edges: some Sequence<Edge>)
        where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        self.init(idValuePairs: values.map { ($0.id, $0) },
                  edges: edges)
    }
    
    init(values: some Sequence<NodeValue>)
        where NodeID == NodeValue
    {
        self.init(idValuePairs: values.map { ($0, $0) })
    }
    
    /**
     Uses a `NodeValue` itself as the ``GraphNode/id`` for its corresponding node
     */
    init(values: some Sequence<NodeValue>,
         edges: some Sequence<(NodeID, NodeID)>)
        where NodeID == NodeValue
    {
        self.init(idValuePairs: values.map { ($0, $0) },
                  edges: edges)
    }
    
    /**
     Uses a `NodeValue` itself as the ``GraphNode/id`` for its corresponding node
     */
    init(values: some Sequence<NodeValue>,
         edges: some Sequence<Edge>)
        where NodeID == NodeValue
    {
        self.init(idValuePairs: values.map { ($0, $0) },
                  edges: edges)
    }
    
    init(idValuePairs: some Sequence<(NodeID, NodeValue)>)
    {
        self.init(idValuePairs: idValuePairs,
                  edges: [Edge]())
    }
    
    /**
     Create a `Graph` that determines ``GraphNode/id``s for new `NodeValue`s via the given closure
     */
    init(idValuePairs: some Sequence<(NodeID, NodeValue)>,
         edges: some Sequence<(NodeID, NodeID)>)
    {
        let actualEdges = edges.map { Edge(from: $0.0, to: $0.1) }
        
        self.init(idValuePairs: idValuePairs,
                  edges: actualEdges)
    }
}
