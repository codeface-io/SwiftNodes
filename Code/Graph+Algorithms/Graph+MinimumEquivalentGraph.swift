import SwiftyToolz

public extension Graph
{
    /**
     Find the [minumum equivalent graph](https://en.wikipedia.org/wiki/Transitive_reduction) of an **acyclic** `Graph`
     
     🛑 This only works on acyclic graphs and might even hang or crash on cyclic ones!
     */
    func makeMinimumEquivalentGraph() -> Graph<NodeID, NodeValue>
    {
        var nonEssentialEdges = EdgeIDs()
        var consideredAncestorsHash = [NodeID: NodeIDs]()
        
        for sourceNode in sources
        {
            // TODO: keep track of visited nodes within each traversal from a source and ignore already visited nodes so we can't get hung up in cycles
            
            nonEssentialEdges += findNonEssentialEdges(around: sourceNode,
                                                       reachedAncestors: [],
                                                       consideredAncestorsHash: &consideredAncestorsHash)
        }
        
        var minimumEquivalentGraph = self
        nonEssentialEdges.forEach { minimumEquivalentGraph.removeEdge(with: $0) }
        return minimumEquivalentGraph
    }
    
    private func findNonEssentialEdges(around node: Node,
                                       reachedAncestors: NodeIDs,
                                       consideredAncestorsHash: inout [NodeID: NodeIDs]) -> EdgeIDs
    {
        let consideredAncestors = consideredAncestorsHash[node.id, default: NodeIDs()]
        let ancestorsToConsider = reachedAncestors - consideredAncestors
        
        if !reachedAncestors.isEmpty && ancestorsToConsider.isEmpty
        {
            // found shortcut edge on a path we've already traversed, so we reached no new ancestors
            return []
        }
        
        consideredAncestorsHash[node.id, default: NodeIDs()] += ancestorsToConsider
        
        var nonEssentialEdges = EdgeIDs()
        
        // base case: add edges from all reached ancestors to all reachable neighbours of node
        
        let descendants = node.descendantIDs
        
        for descendant in descendants
        {
            for ancestor in ancestorsToConsider
            {
                if let nonEssentialEdge = edge(from: ancestor, to: descendant)
                {
                    nonEssentialEdges += nonEssentialEdge.id
                }
            }
        }
        
        // recursive calls on descendants
        
        for descendantID in descendants
        {
            guard let descendant = self.node(for: descendantID) else { continue }
            
            nonEssentialEdges += findNonEssentialEdges(around: descendant,
                                                       reachedAncestors: ancestorsToConsider + node.id,
                                                       consideredAncestorsHash: &consideredAncestorsHash)
        }
        
        return nonEssentialEdges
    }
}
