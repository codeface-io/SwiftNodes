//extension Graph: ExpressibleByArrayLiteral where NodeValue: Identifiable, NodeValue.ID == NodeID
//{
//    public init(arrayLiteral elements: NodeValue...)
//    {
//        self.init(values: elements)
//    }
//}

extension Graph: ExpressibleByArrayLiteral where NodeID == NodeValue
{
    public init(arrayLiteral elements: NodeValue...)
    {
        self.init(values: elements)
    }
}

extension Graph: ExpressibleByDictionaryLiteral
{
    public init(dictionaryLiteral elements: (NodeID, NodeValue)...)
    {
        self.init(valuesByID: .init(uniqueKeysWithValues: elements))
    }
}

public extension Graph
{
    init(values: some Sequence<NodeValue>)
        where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        self.init(valuesByID: .init(values: values))
    }
    
    /**
     Uses the `NodeValue.ID` of a value as the ``GraphNode/id`` for its corresponding node
     */
    init(values: some Sequence<NodeValue>,
         edges: some Sequence<(NodeID, NodeID)>)
        where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        self.init(valuesByID: .init(values: values), edges: edges)
    }
    
    init(values: some Sequence<NodeValue>,
         edgeTuples: some Sequence<(NodeID, NodeID)>)
        where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        self.init(valuesByID: .init(values: values), edges: edgeTuples)
    }
    
    /**
     Uses the `NodeValue.ID` of a value as the ``GraphNode/id`` for its corresponding node
     */
    init(values: some Sequence<NodeValue>,
         edges: some Sequence<Edge>)
        where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        self.init(valuesByID: .init(values: values), edges: edges)
    }
    
    init(values: some Sequence<NodeValue>)
        where NodeID == NodeValue
    {
        self.init(valuesByID: .init(values: values))
    }
    
    /**
     Uses a `NodeValue` itself as the ``GraphNode/id`` for its corresponding node
     */
    init(values: some Sequence<NodeValue>,
         edges: some Sequence<(NodeID, NodeID)>)
        where NodeID == NodeValue
    {
        self.init(valuesByID: .init(values: values),
                  edges: edges)
    }
    
    /**
     Uses a `NodeValue` itself as the ``GraphNode/id`` for its corresponding node
     */
    init(values: some Sequence<NodeValue>,
         edges: some Sequence<Edge>)
        where NodeID == NodeValue
    {
        self.init(valuesByID: .init(values: values), edges: edges)
    }
    
    init(valuesByID: Dictionary<NodeID, NodeValue>)
    {
        self.init(valuesByID: valuesByID, edges: [Edge]())
    }
    
    /**
     Create a `Graph` that determines ``GraphNode/id``s for new `NodeValue`s via the given closure
     */
    init(valuesByID: Dictionary<NodeID, NodeValue>,
         edges: some Sequence<(NodeID, NodeID)>)
    {
        let actualEdges = edges.map { Edge(from: $0.0, to: $0.1) }
        
        self.init(valuesByID: valuesByID, edges: actualEdges)
    }
}
