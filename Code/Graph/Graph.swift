import OrderedCollections
import SwiftyToolz

/**
 Holds `Value`s in unique ``GraphNode``s which can be connected through ``GraphEdge``s
 
 You create `GraphNode`s by inserting `NodeValue`s into the `Graph`, whereby the `Graph` generates the IDs for new nodes according to the closure passed to- or implied by its initializer, see ``Graph/init(nodes:makeNodeIDForValue:)`` and the convenience initializers.
 
 Nodes maintain an order, and so the graph can be sorted, see ``Graph/sort(by:)``.
 */
public struct Graph<NodeID, NodeValue>: Sendable
    where NodeID: Sendable, NodeID: Hashable, NodeValue: Sendable
{
    // MARK: - Initialize
    
    public init(values: [NodeValue]) where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        let nodeArray = values.map { GraphNode(id: $0.id, value: $0) }
        self.init(nodes: OrderedSet(nodeArray))
    }
    
    // TODO: nowhere should the client be required to provide nodes, since nodes contain edge caches. only the graph should create nodes. the client only reads them.
    
    /**
     Uses the `NodeValue.ID` of a value as the ``GraphNode/id`` for its corresponding node
     */
    public init(nodes: OrderedNodes = []) where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        self.init(nodes: nodes) { $0.id }
    }
    
    /**
     Uses a `NodeValue` itself as the ``GraphNode/id`` for its corresponding node
     */
    public init(nodes: OrderedNodes = []) where NodeID == NodeValue
    {
        self.init(nodes: nodes) { $0 }
    }
    
    /**
     Creates a `Graph` that generates ``GraphNode/id``s for new ``GraphNode``s with the given closure
     */
    public init(nodes: OrderedNodes = [],
                makeNodeIDForValue: @Sendable @escaping (NodeValue) -> NodeID)
    {
        nodesByID = .init(uniqueKeysWithValues: nodes.map { ($0.id, $0) })
        self.makeNodeIDForValue = makeNodeIDForValue
    }
    
    // MARK: - Edges
    
    /**
     Removes the corresponding ``GraphEdge``, see ``Graph/remove(_:)``
     */
    public mutating func removeEdge(from origin: Node, to destination: Node)
    {
        removeEdge(from: origin.id, to: destination.id)
    }
    
    /**
     Removes the corresponding ``GraphEdge``, see ``Graph/remove(_:)``
     */
    public mutating func removeEdge(from originID: NodeID, to destinationID: NodeID)
    {
        removeEdge(with: .init(originID, destinationID))
    }
    
    /**
     Removes the corresponding ``GraphEdge``, see ``Graph/remove(_:)``
     */
    public mutating func remove(_ edge: Edge)
    {
        removeEdge(with: edge.id)
    }
    
    /**
     Removes the ``GraphEdge`` with the given ID, also removing it from the caches of its ``GraphEdge/origin`` and ``GraphEdge/destination``
     */
    public mutating func removeEdge(with edgeID: Edge.ID)
    {
        // remove from node caches
        nodesByID[edgeID.originID]?.descendantIDs -= edgeID.destinationID
        nodesByID[edgeID.destinationID]?.ancestorIDs -= edgeID.originID
        
        // remove edge itself
        edgesByID[edgeID] = nil
    }
    
    @discardableResult
    public mutating func addEdge(from origin: Node,
                                 to destination: Node,
                                 count: Int = 1) -> Edge
    {
        addEdge(from: origin.id, to: destination.id, count: count)
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
     The ``GraphEdge`` from `origin` to `destination` if it exists, otherwise `nil`
     */
    public func edge(from origin: Node, to destination: Node) -> Edge?
    {
        edge(from: origin.id, to: destination.id)
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
    public var edges: Dictionary<Edge.ID, Edge>.Values
    {
        edgesByID.values
    }
    
    /**
     All ``GraphEdge``s of the `Graph` hashable by their ``GraphEdge/id-swift.property``
     */
    public private(set) var edgesByID = [Edge.ID: Edge]()
    
    /**
     Shorthand for the full generic type name `GraphEdge<NodeID, NodeValue>`
     */
    public typealias Edge = GraphEdge<NodeID, NodeValue>
    
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
    
    internal let makeNodeIDForValue: @Sendable (NodeValue) -> NodeID
    
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
     Whether the `Graph` contains the given ``GraphNode``
     */
    public func contains(_ node: Node) -> Bool
    {
        contains(node.id)
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
     Sort the ``GraphNode``s of the `Graph` with the given closure
     */
    public mutating func sort(by nodesAreInOrder: (Node, Node) -> Bool)
    {
        nodesByID.values.sort(by: nodesAreInOrder)
    }
    
    /**
     The ``GraphNode/id``s of all ``GraphNode``s of the `Graph`
     */
    public var nodesIDs: OrderedSet<NodeID>
    {
        nodesByID.keys
    }
    
    /**
     All ``GraphNode``s of the `Graph`
     */
    public var nodes: OrderedDictionary<NodeID, Node>.Values
    {
        nodesByID.values
    }
    
    // FIXME: To avoid the warning, update to https://github.com/apple/swift-collections 1.1.0 as soon as that's officially released. It's unclear (to me) how that hasn't happened yet: https://github.com/apple/swift-collections/pull/191#issuecomment-1374861077
    /**
     All ``GraphNode``s of the `Graph` hashable by their ``GraphNode/id``s
     */
    public private(set) var nodesByID = OrderedDictionary<NodeID, Node>()
    
    /**
     Shorthand for `OrderedSet<Node>`
     */
    public typealias OrderedNodes = OrderedSet<Node>
    
    /**
     Shorthand for `Set<Node>`
     */
    public typealias Nodes = Set<Node>
    
    /**
     Shorthand for the `Graph`'s full generic node type `GraphNode<NodeID, NodeValue>`
     */
    public typealias Node = GraphNode<NodeID, NodeValue>
}
