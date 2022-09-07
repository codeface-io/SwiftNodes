import SwiftyToolz

public extension Graph
{
    /**
     Find the total number of all ancestors (predecessors / sources) for every node of an **acyclic** graph.
     */
    func findNumberOfNodeAncestors() -> [(Node, Int)]
    {
        unmarkNodes()
        
        sinks.forEach { getAncestorCount(for: $0) }

        return nodesByValueID.values.map { ($0, $0.marking?.ancestorCount ?? 0) }
    }

    @discardableResult
    private func getAncestorCount(for node: Node) -> Int
    {
        if let marking = node.marking { return marking.ancestorCount }
        
        let marking = node.mark() // mark node as visited to avoid infinite loops in cyclic graphs
        
        let directAncestors = node.ancestors
        let ingoingEdges = directAncestors.compactMap { edge(from: $0, to: node) }
        let directAncestorCount = ingoingEdges.sum { $0.count }
        
        let ancestorCount = directAncestorCount + directAncestors.sum
        {
            getAncestorCount(for: $0)
        }
        
        marking.ancestorCount = ancestorCount
        
        return ancestorCount
    }
}

private extension GraphNode.Marking
{
    var ancestorCount: Int
    {
        get { number1 }
        set { number1 = newValue }
    }
}
