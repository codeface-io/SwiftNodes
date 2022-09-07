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
        OrderedNodes(nodesByValueID.values.filter { $0.ancestors.count == 0 })
    }
    
    var sinks: OrderedNodes
    {
        OrderedNodes(nodesByValueID.values.filter { $0.descendants.count == 0 })
    }
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
}

public extension GraphNode.Marking
{
    static var zero: GraphNode.Marking { .init() }
}
