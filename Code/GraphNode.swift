import SwiftyToolz

public extension Set
{
    func values<Value>() -> [Value] where Element == GraphNode<Value>
    {
        map { $0.value }
    }
}

public extension Array
{
    func values<Value>() -> [Value] where Element == GraphNode<Value>
    {
        map { $0.value }
    }
}

public class GraphNode<Value: Identifiable>: Identifiable, Hashable
{
    // MARK: - Markings for Algorithms
    
    var marking: Marking?
    
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
        
        var number1: Int
        var number2: Int
        var flag1: Bool
        var flag2: Bool
    }
    
    // MARK: - Caches for Accessing Neighbours Quickly
    
    public var neighbours: Set<Node> { ancestors + descendants }
    
    public internal(set) var ancestors = Set<Node>()
    public internal(set) var descendants = Set<Node>()
    
    // MARK: - Basics: Value & Identity
    
    internal init(value: Value) { self.value = value }
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    
    public static func == (lhs: Node, rhs: Node) -> Bool { lhs.id == rhs.id }
    
    public typealias Node = GraphNode<Value>
    
    public var id: Value.ID { value.id }
    
    public private(set) var value: Value
}
