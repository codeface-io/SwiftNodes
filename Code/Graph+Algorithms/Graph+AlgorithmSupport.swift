import SwiftyToolz

public extension Graph
{
    func unmarkNodes()
    {
        setNodeMarkings(to: nil)
    }
    
    func setNodeMarkings(to marking: Node.Marking?)
    {
        for node in nodesByValueID.values
        {
            node.marking = marking
        }
    }
    
    var sources: OrderedNodes
    {
        OrderedNodes(nodesByValueID.values.filter { $0.isSource })
    }
    
    var sinks: OrderedNodes
    {
        OrderedNodes(nodesByValueID.values.filter { $0.isSink })
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
    
    var isSink: Bool { descendants.count == 0 }
    var isSource: Bool { ancestors.count == 0 }
    
    var neighbours: Set<Node> { ancestors + descendants }
}

public extension GraphNode.Marking
{
    static var zero: GraphNode.Marking { .init() }
}

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
