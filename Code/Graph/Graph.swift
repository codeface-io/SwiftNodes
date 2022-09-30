import OrderedCollections
import SwiftyToolz

/**
 Holds values in nodes which can be connected through edges. Nodes maintain an order, and so the graph can be sorted.
 */
public class Graph<NodeID: Hashable, NodeValue>
{
    // MARK: - Initialize
    
    public convenience init(nodes: OrderedNodes = []) where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        self.init(nodes: nodes) { $0.id }
    }
    
    public convenience init(nodes: OrderedNodes = []) where NodeID == NodeValue
    {
        self.init(nodes: nodes) { $0 }
    }
    
    public init(nodes: OrderedNodes = [],
                makeNodeIDForValue: @escaping (NodeValue) -> NodeID)
    {
        nodesByID = .init(uniqueKeysWithValues: nodes.map { ($0.id, $0) })
        self.makeNodeIDForValue = makeNodeIDForValue
    }
    
    // MARK: - Edges
    
    public func remove(_ edge: Edge)
    {
        // remove from node caches
        edge.source.descendants -= edge.target
        edge.target.ancestors -= edge.source
        
        // remove edge itself
        edgesByID[edge.id] = nil
    }
    
    @discardableResult
    public func addEdge(from sourceID: NodeID, to targetID: NodeID) -> Edge?
    {
        guard let source = node(for: sourceID), let target = node(for: targetID) else { return nil }
        return addEdge(from: source, to: target)
    }
    
    @discardableResult
    public func addEdge(from source: Node, to target: Node) -> Edge
    {
        let edgeID = Edge.ID(source: source, target: target)
        
        if let edge = edgesByID[edgeID]
        {
            edge.count += 1
            
            // TODO: maintain count in edge caches in nodes as well, for algorithms that take edge weight into account when traversing the graph, like dijkstra shortest path ...
            
            return edge
        }
        else
        {
            let edge = Edge(from: source, to: target)
            edgesByID[edgeID] = edge
            
            // add to node caches
            source.descendants += target
            target.ancestors += source
            
            return edge
        }
    }
    
    public func edge(from sourceID: NodeID, to targetID: NodeID) -> Edge?
    {
        edgesByID[.init(sourceID: sourceID, targetID: targetID)]
    }
    
    public func edge(from source: Node, to target: Node) -> Edge?
    {
        edgesByID[.init(source: source, target: target)]
    }
    
    public var edges: Dictionary<Edge.ID, Edge>.Values
    {
        edgesByID.values
    }
    
    public private(set) var edgesByID = [Edge.ID: Edge]()
    
    public typealias Edge = GraphEdge<NodeID, NodeValue>
    
    // MARK: - Node Values
    
    /**
     Inserts a new node with the given value into the graph and returns the new node. If a node with the same generated node id already exists, the function returns the existing node.
     */
    @discardableResult
    public func insert(_ value: NodeValue) -> Node
    {
        let nodeID = makeNodeIDForValue(value)
        if let existingNode = nodesByID[nodeID] { return existingNode }
        let node = Node(id: nodeID, value: value)
        nodesByID[nodeID] = node
        return node
    }
    
    internal let makeNodeIDForValue: (NodeValue) -> NodeID
    
    public func value(for nodeID: NodeID) -> NodeValue?
    {
        node(for: nodeID)?.value
    }
    
    public var values: [NodeValue]
    {
        nodes.map { $0.value }
    }
    
    // MARK: - Nodes
    
    public func node(for nodeID: NodeID) -> Node?
    {
        nodesByID[nodeID]
    }
    
    public func sort(by nodesAreInOrder: (Node, Node) -> Bool)
    {
        nodesByID.values.sort(by: nodesAreInOrder)
    }
    
    public var nodesIDs: OrderedSet<NodeID>
    {
        nodesByID.keys
    }
    
    public var nodes: OrderedDictionary<NodeID, Node>.Values
    {
        nodesByID.values
    }
    
    public private(set) var nodesByID = OrderedDictionary<NodeID, Node>()
    
    public typealias OrderedNodes = OrderedSet<Node>
    public typealias Nodes = Set<Node>
    public typealias Node = GraphNode<NodeID, NodeValue>
}
