import SwiftyToolz

public extension Graph
{
    /**
     Find the total (recursive) number of ancestors for each ``GraphNode`` of an **acyclic** `Graph`
     
     The ancestor count of a node is basically the number of other nodes from which the node can be reached. This only works on acyclic graphs right now and might return incorrect results for nodes in cycles.
     
     Ancestor counts can serve as a proxy for [topological sorting](https://en.wikipedia.org/wiki/Topological_sorting).
     
     Note that the worst case space complexity is quadratic in the number of nodes.
     
     - Returns: A dictionary containing the ancestor count for every node ``GraphNode/id`` of the `Graph`
     */
    func findNumberOfNodeAncestors() -> [NodeID: Int]
    {
        var ancestorsByNodeID = [NodeID: Set<NodeID>]()
        
        sinks.forEach
        {
            getAncestors(for: $0.id, ancestorsByNodeID: &ancestorsByNodeID)
        }

        return ancestorsByNodeID.mapValues { $0.count }
    }

    @discardableResult
    private func getAncestors(for node: NodeID,
                              ancestorsByNodeID: inout [NodeID: Set<NodeID>]) -> Set<NodeID>
    {
        if let ancestors = ancestorsByNodeID[node] { return ancestors }
        
        ancestorsByNodeID[node] = [] // mark node as visited to avoid infinite loops in cyclic graphs
        
        guard let directAncestors = self.node(for: node)?.ancestorIDs else
        {
            log(error: "No node for node ID exists, but it should.")
            return []
        }
        
        var ancestors = directAncestors
        
        for directAncestor in directAncestors
        {
            ancestors += getAncestors(for: directAncestor,
                                      ancestorsByNodeID: &ancestorsByNodeID)
        }
        
        ancestorsByNodeID[node] = ancestors
        
        return ancestors
    }
}
