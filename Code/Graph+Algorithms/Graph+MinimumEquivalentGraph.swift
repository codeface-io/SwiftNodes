import SwiftyToolz

public extension Graph
{
    // TODO: this can be accelerated a bit by only working with- and returning Node- and Edge IDs instead of Nodes and Edges. Only for where we actually need the descendant IDs do we need to hash the Node itself.
    
    /**
     Find the [minumum equivalent graph](https://en.wikipedia.org/wiki/Transitive_reduction) of an **acyclic** `Graph`
     
     🛑 This only works on acyclic graphs and might even hang or crash on cyclic ones!
     */
    func makeMinimumEquivalentGraph() -> Graph<NodeID, NodeValue>
    {
        var nonEssentialEdges = Set<Edge>()
        var consideredAncestorsHash = [Node: Nodes]()
        
        for sourceNode in sources
        {
            // TODO: keep track of visited nodes within each traversal from a source and ignore already visited nodes so we can't get hung up in cycles
            
            nonEssentialEdges += findNonEssentialEdges(around: sourceNode,
                                                       reachedAncestors: [],
                                                       consideredAncestorsHash: &consideredAncestorsHash)
        }
        
        var minimumEquivalentGraph = self
        nonEssentialEdges.forEach { minimumEquivalentGraph.removeEdge(with: $0.id) }
        return minimumEquivalentGraph
    }
    
    private func findNonEssentialEdges(around node: Node,
                                       reachedAncestors: Nodes,
                                       consideredAncestorsHash: inout [Node: Nodes]) -> Set<Edge>
    {
        let consideredAncestors = consideredAncestorsHash[node, default: Nodes()]
        let ancestorsToConsider = reachedAncestors - consideredAncestors
        
        if !reachedAncestors.isEmpty && ancestorsToConsider.isEmpty
        {
            // found shortcut edge on a path we've already traversed, so we reached no new ancestors
            return []
        }
        
        consideredAncestorsHash[node, default: Set<Node>()] += ancestorsToConsider
        
        var nonEssentialEdges = Set<Edge>()
        
        // base case: add edges from all reached ancestors to all reachable neighbours of node
        
        let descendants = node.descendantIDs.compactMap { self.node(for: $0) }
        
        for descendant in descendants
        {
            for ancestor in ancestorsToConsider
            {
                if let nonEssentialEdge = edge(from: ancestor.id, to: descendant.id)
                {
                    nonEssentialEdges += nonEssentialEdge
                }
            }
        }
        
        // recursive calls on descendants
        
        for descendant in descendants
        {
            nonEssentialEdges += findNonEssentialEdges(around: descendant,
                                                       reachedAncestors: ancestorsToConsider + node,
                                                       consideredAncestorsHash: &consideredAncestorsHash)
        }
        
        return nonEssentialEdges
    }
}
