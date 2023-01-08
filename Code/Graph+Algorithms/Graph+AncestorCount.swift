import SwiftyToolz

public extension Graph
{
    /**
     Find the total (recursive) number of ancestors for each ``GraphNode`` of an **acyclic** `Graph`
     
     The ancestor count of a node is basically the number of other nodes from which the node can be reached. This only works on acyclic graphs right now and might return incorrect results for nodes in cycles.
     
     Ancestor counts can serve as a proxy for [topological sorting](https://en.wikipedia.org/wiki/Topological_sorting).
     
     - Returns: Every ``GraphNode`` of the `Graph` together with its ancestor count
     */
    func findNumberOfNodeAncestors() -> [(Node, Int)]
    {
        var ancestorCountByNode = [Node: Int]()
        
        sinks.forEach
        {
            getAncestorCount(for: $0, ancestorCountByNode: &ancestorCountByNode)
        }

        return nodesByID.values.map { ($0, ancestorCountByNode[$0] ?? 0) }
    }

    @discardableResult
    private func getAncestorCount(for node: Node,
                                  ancestorCountByNode: inout [Node: Int]) -> Int
    {
        if let ancestorCount = ancestorCountByNode[node] { return ancestorCount }
        
        ancestorCountByNode[node] = 0 // mark node as visited to avoid infinite loops in cyclic graphs
        
        let directAncestors = node.ancestors
        let ingoingEdges = directAncestors.compactMap { edge(from: $0, to: node) }
        let directAncestorCount = ingoingEdges.sum { $0.count }
        
        let ancestorCount = directAncestorCount + directAncestors.sum
        {
            getAncestorCount(for: $0, ancestorCountByNode: &ancestorCountByNode)
        }
        
        ancestorCountByNode[node] = ancestorCount
        
        return ancestorCount
    }
}
