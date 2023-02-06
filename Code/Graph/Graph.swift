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
                edges: [Edge] = [])
    {
        // set nodes with their neighbour caches
        
        let idNodePairs = idValuePairs.map { ($0.0 , Node(id: $0.0, value: $0.1)) }
        var nodesByIDTemporary = [NodeID: Node](uniqueKeysWithValues: idNodePairs)
        
        edges.forEach
        {
            nodesByIDTemporary[$0.originID]?.descendantIDs.insert($0.destinationID)
            nodesByIDTemporary[$0.destinationID]?.ancestorIDs.insert($0.originID)
        }
        
        nodesByID = nodesByIDTemporary
        
        // set edges and node ID retriever
        
        edgesByID = .init(values: edges)
    }
    
    public init()
    {
        nodesByID = .init()
        edgesByID = .init()
    }
    
    // MARK: - Remove Nodes
    
    mutating func removeNode(with nodeID: NodeID)
    {
        guard let node = nodesByID[nodeID] else { return }
        
        nodesByID[nodeID] = nil
        
        for ancestorID in node.ancestorIDs
        {
            removeEdge(with: .init(ancestorID, nodeID))
        }
        
        for descendantID in node.descendantIDs
        {
            removeEdge(with: .init(nodeID, descendantID))
        }
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
     Removes the ``GraphEdge``s with the given IDs, also removing them from node neighbour caches
     */
    public mutating func removeEdges(with edgeIDs: EdgeIDs)
    {
        edgeIDs.forEach { removeEdge(with: $0) }
    }
    
    /**
     Removes the ``GraphEdge`` with the given ID, also removing it from node neighbour caches
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
        edge(with: .init(originID, destinationID))
    }
    
    /**
     The ``GraphEdge`` with the given ID if the edge exists, otherwise `nil`
     */
    public func edge(with edgeID: Edge.ID) -> Edge?
    {
        edgesByID[edgeID]
    }
    
    /**
     Whether the `Graph` contains a ``GraphEdge`` with the given ``GraphEdge/id-swift.property``
     */
    public func contains(_ edgeID: Edge.ID) -> Bool
    {
        edgesByID.keys.contains(edgeID)
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
    
    // MARK: - Values
    
    public subscript(_ nodeID: NodeID) -> NodeValue?
    {
        get
        {
            nodesByID[nodeID]?.value
        }
        
        set
        {
            guard let newValue else
            {
                removeNode(with: nodeID)
                return
            }
            
            update(newValue, for: nodeID)
        }
    }
    
    @discardableResult
    public mutating func insert(_ value: NodeValue) -> Node where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        update(value, for: value.id)
    }
    
    @discardableResult
    public mutating func insert(_ value: NodeValue) -> Node where NodeID == NodeValue
    {
        update(value, for: value)
    }
    
    /**
     Insert a `NodeValue` and get the (new) ``GraphNode`` that stores it
     
     - Returns: The (possibly new) ``GraphNode`` holding the value
     */
    @discardableResult
    public mutating func update(_ value: NodeValue, for nodeID: NodeID) -> Node
    {
        if var node = nodesByID[nodeID]
        {
            node.value = value
            nodesByID[nodeID] = node
            return node
        }
        else
        {
            let node = Node(id: nodeID, value: value)
            nodesByID[nodeID] = node
            return node
        }
    }
    
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
    public var values: some Collection<NodeValue>
    {
        nodesByID.values.map { $0.value }
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
    init(values: some Sequence<Value>) where Value: Identifiable, Value.ID == Key
    {
        self.init(uniqueKeysWithValues: values.map({ ($0.id, $0) }))
    }
}
