import SwiftyToolz

public extension Graph
{
    /**
     Find the total (recursive) number of ancestors for each ``GraphNode`` of an **acyclic** `Graph`
     
     The ancestor count of a node is basically the number of other nodes from which the node can be reached. This only works on acyclic graphs right now and might return incorrect results for nodes in cycles.
     
     Ancestor counts can serve as a proxy for [topological sorting](https://en.wikipedia.org/wiki/Topological_sorting).
     
     - Returns: Every ``GraphNode`` of the `Graph` together with its ancestor count
     */
    func findNumberOfNodeAncestors() -> [(NodeID, Int)]
    {
        var ancestorCountByNodeID = [NodeID: Int]()
        
        sinks.forEach
        {
            getAncestorCount(for: $0.id, ancestorCountByNodeID: &ancestorCountByNodeID)
        }

        return nodesByID.keys.map { ($0, ancestorCountByNodeID[$0] ?? 0) }
    }

    @discardableResult
    private func getAncestorCount(for nodeID: NodeID,
                                  ancestorCountByNodeID: inout [NodeID: Int]) -> Int
    {
        if let ancestorCount = ancestorCountByNodeID[nodeID] { return ancestorCount }
        
        ancestorCountByNodeID[nodeID] = 0 // mark node as visited to avoid infinite loops in cyclic graphs
        
        guard let directAncestorIDs = self.node(for: nodeID)?.ancestorIDs else
        {
            log(error: "No node for node ID exists, but it should.")
            return 0
        }
        
        let ingoingEdges = directAncestorIDs.compactMap { edge(from: $0, to: nodeID) }
        let directAncestorCount = ingoingEdges.sum { $0.count }
        
        let ancestorCount = directAncestorCount + directAncestorIDs.sum
        {
            getAncestorCount(for: $0, ancestorCountByNodeID: &ancestorCountByNodeID)
        }
        
        ancestorCountByNodeID[nodeID] = ancestorCount
        
        return ancestorCount
    }
}
