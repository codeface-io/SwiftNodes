import SwiftyToolz

public class GraphEdge<NodeID: Hashable, NodeValue>: Identifiable, Hashable
{
    // MARK: - Initialize
    
    internal init(from source: Node, to target: Node)
    {
        self.source = source
        self.target = target
        
        count = 1
    }
    
    // MARK: - Hashability
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    public static func == (lhs: Edge, rhs: Edge) -> Bool { lhs === rhs }
    public typealias Edge = GraphEdge<NodeID, NodeValue>
    
    // MARK: - Identity
    
    public var id: ID { ID(source: source, target: target) }
    
    public struct ID: Hashable
    {   
        internal init(source: Node, target: Node)
        {
            self.init(sourceID: source.id, targetID: target.id)
        }
        
        internal init(sourceID: NodeID, targetID: NodeID)
        {
            self.sourceID = sourceID
            self.targetID = targetID
        }
        
        let sourceID: NodeID
        let targetID: NodeID
    }
    
    // MARK: - Basics
    
    public var count: Int
    
    public let source: Node
    public let target: Node
    
    public typealias Node = GraphNode<NodeID, NodeValue>
}
