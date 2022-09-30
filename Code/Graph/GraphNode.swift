import SwiftyToolz

public class GraphNode<ID: Hashable, Value>: Identifiable, Hashable
{
    // MARK: - Marking for Algorithms
    
    public var marking: Marking?
    
    public class Marking
    {
        public init(number1: Int = 0, number2: Int = 0,
                    flag1: Bool = false, flag2: Bool = false)
        {
            self.number1 = number1
            self.number2 = number2
            self.flag1 = flag1
            self.flag2 = flag2
        }
        
        var number1, number2: Int
        var flag1, flag2: Bool
    }
    
    // MARK: - Caches for Accessing Neighbours Quickly
    
    public var isSink: Bool { descendants.isEmpty }
    public var isSource: Bool { ancestors.isEmpty }
    
    var neighbours: Set<Node> { ancestors + descendants }
    
    public internal(set) var ancestors = Set<Node>()
    public internal(set) var descendants = Set<Node>()
    
    // MARK: - Hashability
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    public static func == (lhs: Node, rhs: Node) -> Bool { lhs === rhs }
    public typealias Node = GraphNode<ID, Value>
    
    // MARK: - Identity & Value
    
    internal init(id: ID, value: Value)
    {
        self.id = id
        self.value = value
    }
    
    public let id: ID
    public let value: Value
}
