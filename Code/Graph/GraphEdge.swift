import SwiftyToolz

public class GraphEdge<NodeID: Hashable, NodeValue>: Identifiable, Hashable
{
    // MARK: - Hashability
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    public static func == (lhs: Edge, rhs: Edge) -> Bool { lhs === rhs }
    public typealias Edge = GraphEdge<NodeID, NodeValue>
    
    // MARK: - Identity
    
    public var id: ID { ID(source, target) }
    
    public struct ID: Hashable
    {   
        internal init(_ source: Node, _ target: Node)
        {
            self.init(source.id, target.id)
        }
        
        internal init(_ sourceID: NodeID, _ targetID: NodeID)
        {
            self.sourceID = sourceID
            self.targetID = targetID
        }
        
        let sourceID: NodeID
        let targetID: NodeID
    }
    
    // MARK: - Basics
    
    internal init(from source: Node, to target: Node, count: Int = 1)
    {
        self.source = source
        self.target = target
        
        self.count = count
    }
    
    public internal(set) var count: Int
    
    public let source: Node
    public let target: Node
    
    public typealias Node = GraphNode<NodeID, NodeValue>
}
