import SwiftyToolz

extension Graph: Sendable where NodeID: Sendable, NodeValue: Sendable {}
extension Graph: Equatable where NodeValue: Equatable {}

/**
 Holds `Value`s in unique ``GraphNode``s which can be connected through ``GraphEdge``s
 
 The `Graph` creates `GraphNode`s when you insert `NodeValue`s into it, whereby the `Graph` determines the node IDs for new values according to the closure passed to- or implied by its initializer, see ``Graph/init(nodes:determineNodeIDForNewValue:)`` and other initializers.
 
 A `Graph` is Equatable if its `NodeValue` is. Equatability excludes the `determineNodeIDForNewValue` closure mentioned above.
 */
public struct Graph<NodeID: Hashable, NodeValue>
{
    // MARK: - Initialize
    
    /**
     Uses the `NodeValue.ID` of a value as the ``GraphNode/id`` for its corresponding node
     */
    public init(values: [NodeValue],
                edges: [(NodeID, NodeID)]) where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        self.init(idValuePairs: values.map { ($0.id, $0) },
                  edges: edges)
    }
    
    /**
     Uses the `NodeValue.ID` of a value as the ``GraphNode/id`` for its corresponding node
     */
    public init(values: [NodeValue],
                edges: [Edge] = []) where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        self.init(idValuePairs: values.map { ($0.id, $0) },
                  edges: edges)
    }
    
    /**
     Uses a `NodeValue` itself as the ``GraphNode/id`` for its corresponding node
     */
    public init(values: [NodeValue],
                edges: [(NodeID, NodeID)]) where NodeID == NodeValue
    {
        self.init(idValuePairs: values.map { ($0, $0) },
                  edges: edges)
    }
    
    /**
     Uses a `NodeValue` itself as the ``GraphNode/id`` for its corresponding node
     */
    public init(values: [NodeValue],
                edges: [Edge] = []) where NodeID == NodeValue
    {
        self.init(idValuePairs: values.map { ($0, $0) },
                  edges: edges)
    }
    
    /**
     Create a `Graph` that determines ``GraphNode/id``s for new `NodeValue`s via the given closure
     */
    public init(idValuePairs: [(NodeID, NodeValue)],
                edges: [(NodeID, NodeID)])
    {
        let actualEdges = edges.map { Edge(from: $0.0, to: $0.1) }
        
        self.init(idValuePairs: idValuePairs, edges: actualEdges)
    }
    
    /**
     Create a `Graph` that determines ``GraphNode/id``s for new `NodeValue`s via the given closure
     */
    public init(idValuePairs: [(NodeID, NodeValue)],
                edges: (some Collection<Edge>)? = nil)
    {
        // set nodes with their neighbour caches
        
        let idNodePairs = idValuePairs.map { ($0.0 , Node(id: $0.0, value: $0.1)) }
        var nodesByIDTemporary = [NodeID: Node](uniqueKeysWithValues: idNodePairs)
        
        edges?.forEach
        {
            nodesByIDTemporary[$0.originID]?.descendantIDs.insert($0.destinationID)
            nodesByIDTemporary[$0.destinationID]?.ancestorIDs.insert($0.originID)
        }
        
        nodesByID = nodesByIDTemporary
        
        // set edges and node ID retriever
        
        if let edges
        {
            edgesByID = .init(values: edges)
        }
        else
        {
            edgesByID = .init()
        }
    }
    
    public init()
    {
        nodesByID = .init()
        edgesByID = .init()
    }

    // MARK: - Edges
    
    /**
     All ``GraphEdge``s of the `Graph` hashable by their ``GraphEdge/id-swift.property``
     */
    public internal(set) var edgesByID: [Edge.ID: Edge]
    
    /**
     Shorthand for `Set<Edge.ID>`
     */
    public typealias EdgeIDs = Set<Edge.ID>
    
    /**
     Shorthand for the full generic type name `GraphEdge<NodeID>`
     */
    public typealias Edge = GraphEdge<NodeID>
    
    // MARK: - Nodes
    
    /**
     All ``GraphNode``s of the `Graph` hashable by their ``GraphNode/id``s
     */
    public internal(set) var nodesByID = [NodeID: Node]()
    
    /**
     Shorthand for the `Graph`'s full generic node type `GraphNode<NodeID, NodeValue>`
     */
    public typealias Node = GraphNode<NodeID, NodeValue>
    
    /**
     Shorthand for `Set<NodeID>`
     */
    public typealias NodeIDs = Set<NodeID>
}
