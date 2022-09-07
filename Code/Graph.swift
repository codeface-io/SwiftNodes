import OrderedCollections
import SwiftyToolz

/**
 Holds values in nodes which can be connected through edges.
 
 Nodes maintain an order, and the graph can be sorted. Values must be `Identifiable` and `Hashable`.
 */
public struct Graph<NodeValue: Identifiable & Hashable>
{
    // MARK: - Initialize
    
    public init(nodes: OrderedNodes = [])
    {
        self.nodesByValueID = .init(uniqueKeysWithValues: nodes.map { ($0.value.id, $0) })
    }
    
    // MARK: - Edges
    
    public mutating func remove(_ edge: Edge)
    {
        // remove from node caches
        edge.source.descendants -= edge.target
        edge.target.ancestors -= edge.source
        
        // remove edge itself
        edgesByID[edge.id] = nil
    }
    
    @discardableResult
    public mutating func addEdge(from source: Node, to target: Node) -> Edge
    {
        let edgeID = Edge.ID(sourceValue: source.value, targetValue: target.value)
        
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
    
    public func edge(from source: Node, to target: Node) -> Edge?
    {
        edgesByID[.init(sourceValue: source.value, targetValue: target.value)]
    }
    
    public var edges: [Edge] { Array(edgesByID.values) }
    
    internal var edgesByID = [Edge.ID: Edge]()
    
    public typealias Edge = GraphEdge<NodeValue>
    
    // MARK: - Nodes
    
    public var nodes: OrderedNodes { OrderedSet(nodesByValueID.values) }
    
    public internal(set) var nodesByValueID = OrderedDictionary<NodeValue.ID, Node>()
    
    public typealias OrderedNodes = OrderedSet<Node>
    public typealias Nodes = Set<Node>
    public typealias Node = GraphNode<NodeValue>
}
