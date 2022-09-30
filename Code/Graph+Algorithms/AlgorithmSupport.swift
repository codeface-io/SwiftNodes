import SwiftyToolz

public extension Graph
{
    func unmarkNodes()
    {
        setNodeMarkings(to: nil)
    }
    
    func setNodeMarkings(to marking: Node.Marking?)
    {
        for node in nodesByID.values
        {
            node.marking = marking
        }
    }
    
    var sources: OrderedNodes
    {
        OrderedNodes(nodesByID.values.filter { $0.isSource })
    }
    
    var sinks: OrderedNodes
    {
        OrderedNodes(nodesByID.values.filter { $0.isSink })
    }
}

public extension GraphEdge
{
    func `is`(`in` nodes: Set<Node>) -> Bool
    {
        self.nodes.isSubset(of: nodes)
    }
    
    var nodes: Set<Node> { [source, target] }
}

public extension GraphNode
{
    var isMarked: Bool { marking != nil }
    
    @discardableResult
    func mark(with marking: Marking = .zero) -> Marking
    {
        self.marking = marking
        return marking
    }
    
    var isSink: Bool { descendants.isEmpty }
    var isSource: Bool { ancestors.isEmpty }
    
    var neighbours: Set<Node> { ancestors + descendants }
}

public extension GraphNode.Marking
{
    static var zero: GraphNode.Marking { .init() }
}

// TODO: why must we specialize the GraphNode ID type when we don't need to know the ID type here? are their new Swift 5.7 features to writes this better??
public extension Set
{
    func values<ID, Value>() -> [Value] where Element == GraphNode<ID, Value>
    {
        map { $0.value }
    }
}

public extension Array
{
    func values<ID, Value>() -> [Value] where Element == GraphNode<ID, Value>
    {
        map { $0.value }
    }
}
