import SwiftyToolz

public typealias HashableValuesGraph<Value: Hashable, EdgeWeight: Numeric> = Graph<Value, Value, EdgeWeight>
public typealias IdentifiableValuesGraph<Value: Identifiable, EdgeWeight: Numeric> = Graph<Value.ID, Value, EdgeWeight>

extension Graph: Sendable where NodeID: Sendable, NodeValue: Sendable, EdgeWeight: Sendable {}
extension Graph: Equatable where NodeValue: Equatable {}
extension Graph: Codable where NodeID: Codable, NodeValue: Codable, EdgeWeight: Codable {}

/**
 Holds `Value`s in unique ``GraphNode``s which can be connected through ``GraphEdge``s
 
 The `Graph` creates `GraphNode`s when you insert `NodeValue`s into it, whereby the `Graph` determines the node IDs for new values according to the closure passed to- or implied by its initializer, see ``Graph/init(nodes:determineNodeIDForNewValue:)`` and other initializers.
 
 A `Graph` is Equatable if its `NodeValue` is. Equatability excludes the `determineNodeIDForNewValue` closure mentioned above.
 */
public struct Graph<NodeID: Hashable, NodeValue, EdgeWeight: Numeric>
{
    // MARK: - Initialize
    
    /**
     Create a `Graph` that determines ``GraphNode/id``s for new `NodeValue`s via the given closure
     */
    public init(valuesByID: Dictionary<NodeID, NodeValue>,
                edges: some Sequence<Edge>)
    {
        // create nodes with their neighbour caches
        
        let idNodePairs = valuesByID.map { ($0.0 , Node(id: $0.0, value: $0.1)) }
        var nodesByIDTemporary = [NodeID: Node](uniqueKeysWithValues: idNodePairs)
        
        edges.forEach
        {
            nodesByIDTemporary[$0.originID]?.descendantIDs.insert($0.destinationID)
            nodesByIDTemporary[$0.destinationID]?.ancestorIDs.insert($0.originID)
        }
        
        // set nodes and edges
        
        nodesByID = nodesByIDTemporary
        edgesByID = .init(values: edges)
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
    public typealias Edge = GraphEdge<NodeID, EdgeWeight>
    
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
