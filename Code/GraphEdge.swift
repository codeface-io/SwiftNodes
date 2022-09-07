import SwiftyToolz

public class GraphEdge<NodeValue: Identifiable>: Identifiable, Hashable
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
    
    public static func == (lhs: Edge, rhs: Edge) -> Bool { lhs.id == rhs.id }
    
    public typealias Edge = GraphEdge<NodeValue>
    
    // MARK: - Identity
    
    public var id: ID { ID(sourceValue: source.value, targetValue: target.value) }
    
    public struct ID: Hashable
    {
        init(sourceValue: NodeValue, targetValue: NodeValue)
        {
            self.init(sourceValueID: sourceValue.id, targetValueID: targetValue.id)
        }
        
        init(sourceValueID: NodeValue.ID, targetValueID: NodeValue.ID)
        {
            self.sourceValueID = sourceValueID
            self.targetValueID = targetValueID
        }
        
        let sourceValueID: NodeValue.ID
        let targetValueID: NodeValue.ID
    }
    
    // MARK: - Basic Data
    
    var nodes: Set<Node> { [source, target] }
    
    public var count: Int
    
    public let source: Node
    public let target: Node
    
    public typealias Node = GraphNode<NodeValue>
}
