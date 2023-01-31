import SwiftyToolz

extension Graph: Sendable where NodeID: Sendable, NodeValue: Sendable {}

extension Graph: Equatable where NodeValue: Equatable
{
    // TODO: why is this not generated automatically since all properties of the Graph struct are Equatable in this case???
    public static func == (lhs: Graph<NodeID, NodeValue>,
                           rhs: Graph<NodeID, NodeValue>) -> Bool
    {
        lhs.edgesByID == rhs.edgesByID && lhs.nodesByID == rhs.nodesByID
    }
}

/**
 Holds `Value`s in unique ``GraphNode``s which can be connected through ``GraphEdge``s
 
 You create `GraphNode`s by inserting `NodeValue`s into the `Graph`, whereby the `Graph` generates the IDs for new nodes according to the closure passed to- or implied by its initializer, see ``Graph/init(nodes:makeNodeIDForValue:)`` and the convenience initializers.
 
 Nodes maintain an order, and so the graph can be sorted, see ``Graph/sort(by:)``.
 */
public struct Graph<NodeID: Hashable, NodeValue>
{
    // MARK: - Initialize
    // FIXME: turn parameters from arrays into sets to not falsely suggest order matters
    
    /**
     Uses the `NodeValue.ID` of a value as the ``GraphNode/id`` for its corresponding node
     */
    public init(values: [NodeValue] = [],
                edges: [(NodeID, NodeID)]) where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        self.init(values: values, edges: edges) { $0.id }
    }
    
    /**
     Uses the `NodeValue.ID` of a value as the ``GraphNode/id`` for its corresponding node
     */
    public init(values: [NodeValue] = [],
                edges: [Edge] = []) where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        self.init(values: values, edges: edges) { $0.id }
    }
    
    /**
     Uses a `NodeValue` itself as the ``GraphNode/id`` for its corresponding node
     */
    public init(values: [NodeValue] = [],
                edges: [(NodeID, NodeID)]) where NodeID == NodeValue
    {
        self.init(values: values, edges: edges) { $0 }
    }
    
    /**
     Uses a `NodeValue` itself as the ``GraphNode/id`` for its corresponding node
     */
    public init(values: [NodeValue] = [],
                edges: [Edge] = []) where NodeID == NodeValue
    {
        self.init(values: values, edges: edges) { $0 }
    }
    
    /**
     Creates a `Graph` that generates ``GraphNode/id``s for new ``GraphNode``s with the given closure
     */
    public init(values: [NodeValue] = [],
                edges: [(NodeID, NodeID)],
                makeNodeIDForValue: @Sendable @escaping (NodeValue) -> NodeID)
    {
        let actualEdges = edges.map { Edge(from: $0.0, to: $0.1) }
        
        self.init(values: values,
                  edges: actualEdges,
                  makeNodeIDForValue: makeNodeIDForValue)
    }
    
    /**
     Creates a `Graph` that generates ``GraphNode/id``s for new ``GraphNode``s with the given closure
     */
    public init(values: [NodeValue] = [],
                edges: [Edge] = [],
                makeNodeIDForValue: @Sendable @escaping (NodeValue) -> NodeID)
    {
        // set nodes with their neighbour caches
        
        let nodes = values.map { Node(id: makeNodeIDForValue($0), value: $0) }
        var nodesByIDTemporary = [NodeID: Node](values: nodes) { $0.id }
        
        edges.forEach
        {
            nodesByIDTemporary[$0.originID]?.descendantIDs.insert($0.destinationID)
            nodesByIDTemporary[$0.destinationID]?.ancestorIDs.insert($0.originID)
        }
        
        nodesByID = nodesByIDTemporary
        
        // set edges and node ID retriever
        
        edgesByID = .init(values: edges) { $0.id }
        
        self.makeNodeIDForValue = makeNodeIDForValue
    }
    
    // MARK: - Edges
    
    /**
     Removes the corresponding ``GraphEdge``, see ``Graph/removeEdge(with:)``
     */
    @discardableResult
    public mutating func removeEdge(from originID: NodeID,
                                    to destinationID: NodeID) -> Edge?
    {
        removeEdge(with: .init(originID, destinationID))
    }
    
    /**
     Removes the ``GraphEdge`` with the given ID, also removing it from the caches of its ``GraphEdge/origin`` and ``GraphEdge/destination``
     */
    @discardableResult
    public mutating func removeEdge(with edgeID: Edge.ID) -> Edge?
    {
        // remove from node caches
        nodesByID[edgeID.originID]?.descendantIDs -= edgeID.destinationID
        nodesByID[edgeID.destinationID]?.ancestorIDs -= edgeID.originID
        
        // remove edge itself
        let edge = edgesByID[edgeID]
        edgesByID[edgeID] = nil
        return edge
    }
    
    /**
     Adds a ``GraphEdge`` from one ``GraphNode`` to another
     
     This also adds the `originID` and `destinationID` to the corresponding node's neighbour caches, see ``GraphNode``
     
     - Returns: The new ``GraphEdge`` if none existed from `originID` to `destinationID`, otherwise the existing ``GraphEdge`` with its ``GraphEdge/count`` increased by the given `count`
     */
    @discardableResult
    public mutating func addEdge(from originID: NodeID,
                                 to destinationID: NodeID,
                                 count: Int = 1) -> Edge
    {
        let edgeID = Edge.ID(originID, destinationID)
        
        if var existingEdge = edgesByID[edgeID]
        {
            edgesByID[edgeID]?.count += count
            existingEdge.count += count
            
            // TODO: maintain count in edge caches in nodes as well, for algorithms that take edge weight into account when traversing the graph, like dijkstra shortest path ...
            
            return existingEdge
        }
        else
        {
            let edge = Edge(from: originID, to: destinationID, count: count)
            edgesByID[edgeID] = edge
            
            // add to node caches
            nodesByID[originID]?.descendantIDs += destinationID
            nodesByID[destinationID]?.ancestorIDs += originID
            
            return edge
        }
    }
    
    /**
     The ``GraphEdge`` between the corresponding nodes if it exists, otherwise `nil`
     */
    public func edge(from originID: NodeID, to destinationID: NodeID) -> Edge?
    {
        guard contains(originID), contains(destinationID) else { return nil }
        return edgesByID[.init(originID, destinationID)]
    }
    
    /**
     All ``GraphEdge``s of the `Graph`
     */
    public var edges: some Collection<Edge>
    {
        edgesByID.values
    }
    
    /**
     All ``GraphEdge/id-swift.property``s of the ``GraphEdge``s of the `Graph`
     */
    public var edgeIDs: some Collection<Edge.ID>
    {
        edgesByID.keys
    }
    
    /**
     All ``GraphEdge``s of the `Graph` hashable by their ``GraphEdge/id-swift.property``
     */
    public private(set) var edgesByID: [Edge.ID: Edge]
    
    /**
     Shorthand for the full generic type name `GraphEdge<NodeID, NodeValue>`
     */
    public typealias Edge = GraphEdge<NodeID>
    
    /**
     Shorthand for `Set<Edge.ID>`
     */
    public typealias EdgeIDs = Set<Edge.ID>
    
    // MARK: - Node Values
    
    /**
     Insert a `NodeValue` and get the (new) ``GraphNode`` that stores it
     
     - Returns: The existing ``GraphNode`` if one with the generated ``GraphNode/id`` already exists (see ``Graph/init(nodes:makeNodeIDForValue:)``), otherwise a newly created ``GraphNode``.
     */
    @discardableResult
    public mutating func insert(_ value: NodeValue) -> Node
    {
        let nodeID = makeNodeIDForValue(value)
        if let existingNode = nodesByID[nodeID] { return existingNode }
        let node = Node(id: nodeID, value: value)
        nodesByID[nodeID] = node
        return node
    }
    
    public let makeNodeIDForValue: @Sendable (NodeValue) -> NodeID
    
    /**
     ``GraphNode/value`` of the ``GraphNode`` with the given ``GraphNode/id`` if one exists, otherwise `nil`
     */
    public func value(for nodeID: NodeID) -> NodeValue?
    {
        node(for: nodeID)?.value
    }
    
    /**
     All `NodeValue`s of the `Graph`
     */
    public var values: [NodeValue]
    {
        nodes.map { $0.value }
    }
    
    // MARK: - Nodes
    
    /**
     All source nodes of the `Graph`, see ``GraphNode/isSource``
     */
    public var sources: [Node]
    {
        nodesByID.values.filter { $0.isSource }
    }
    
    /**
     All sink nodes of the `Graph`, see ``GraphNode/isSink``
     */
    public var sinks: [Node]
    {
        nodesByID.values.filter { $0.isSink }
    }
    
    /**
     Whether the `Graph` contains a ``GraphNode`` with the given ``GraphNode/id``
     */
    public func contains(_ nodeID: NodeID) -> Bool
    {
        node(for: nodeID) != nil
    }
    
    /**
     ``GraphNode`` with the given ``GraphNode/id`` if one exists, otherwise `nil`
     */
    public func node(for nodeID: NodeID) -> Node?
    {
        nodesByID[nodeID]
    }
    
    /**
     All ``GraphNode``s of the `Graph`
     */
    public var nodes: some Collection<Node>
    {
        nodesByID.values
    }
    
    /**
     The ``GraphNode/id``s of all ``GraphNode``s of the `Graph`
     */
    public var nodeIDs: some Collection<NodeID>
    {
        nodesByID.keys
    }
    
    /**
     All ``GraphNode``s of the `Graph` hashable by their ``GraphNode/id``s
     */
    public private(set) var nodesByID = [NodeID: Node]()
    
    /**
     Shorthand for the `Graph`'s full generic node type `GraphNode<NodeID, NodeValue>`
     */
    public typealias Node = GraphNode<NodeID, NodeValue>
    
    /**
     Shorthand for `Set<NodeID>`
     */
    public typealias NodeIDs = Set<NodeID>
}

extension Dictionary
{
    init(values: some Sequence<Value>, getKeyFromValue: (Value) -> Key)
    {
        self.init(uniqueKeysWithValues: values.map({ (getKeyFromValue($0), $0) }))
    }
}
