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
