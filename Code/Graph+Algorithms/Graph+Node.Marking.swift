import SwiftyToolz

public extension Graph
{
    /**
     Sets ``GraphNode/marking-swift.property`` of all the `Graph`'s ``GraphNode``s back to `nil`
     */
    func unmarkNodes()
    {
        setNodeMarkings(to: nil)
    }
    
    /**
     Mark all the `Graph`'s ``GraphNode``s with the given ``GraphNode/Marking-swift.class`` or unmark them passing `nil`
     */
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
    /**
     Whether ``GraphNode/marking-swift.property`` is not `nil`
     */
    var isMarked: Bool { marking != nil }
    
    /**
     Mark the `GraphNode` with a given ``GraphNode/Marking-swift.class`` or just call `mark()` to mark it with ``GraphNode/Marking-swift.class/zero``
     */
    @discardableResult
    func mark(with marking: Marking = .zero) -> Marking
    {
        self.marking = marking
        return marking
    }
}

public extension GraphNode.Marking
{
    /**
     Empty `GraphNode.Marking` for generally marking a ``GraphNode``, see ``GraphNode/mark(with:)``
     */
    static var zero: GraphNode.Marking { .init() }
}
