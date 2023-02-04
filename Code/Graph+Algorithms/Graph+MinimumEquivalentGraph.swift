import SwiftyToolz

public extension Graph
{
    /**
     Find the [minumum equivalent graph](https://en.wikipedia.org/wiki/Transitive_reduction) of an **acyclic** `Graph`
     
     🛑 This only works on acyclic graphs and might even hang or crash on cyclic ones!
     */
    func makeMinimumEquivalentGraph() -> Graph<NodeID, NodeValue>
    {   
        var minimumEquivalentGraph = self
        minimumEquivalentGraph.removeEdges(with: findTransitiveEdges())
        return minimumEquivalentGraph
    }
    
    /**
     Find the edges of the [minumum equivalent graph](https://en.wikipedia.org/wiki/Transitive_reduction) of an **acyclic** `Graph`
     
     These are the edges which are **not** in the transitive reduction.
     
     🛑 This only works on acyclic graphs and might even hang or crash on cyclic ones!
     */
    func findTransitiveEdges() -> EdgeIDs
    {
        var idOfTransitiveEdges = EdgeIDs() // or "shortcuts" of longer paths; or "implied" edges
        
        var consideredAncestorsHash = [NodeID: NodeIDs]()
        
        // TODO: keep track of visited nodes within each traversal from a node and ignore already visited nodes so we can't get hung up in cycles. be aware that iterating through only the sources in this loop will also not work when graphs are potentially cyclic or even exclusively made of cycles (i.e. have no sources)!
        for sourceNode in sources
        {
            idOfTransitiveEdges += findTransitiveEdges(around: sourceNode,
                                                       reachedAncestors: [],
                                                       consideredAncestorsHash: &consideredAncestorsHash)
        }
        
        return idOfTransitiveEdges
    }
    
    private func findTransitiveEdges(around node: Node,
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
        
        var idsOfTransitiveEdges = EdgeIDs()
        
        // base case: add edges from all reached ancestors to all reachable neighbours of node
        
        let descendants = node.descendantIDs
        
        for descendant in descendants
        {
            for ancestor in ancestorsToConsider
            {
                let edgeID = Edge.ID(ancestor, descendant)
                
                if contains(edgeID)
                {
                    idsOfTransitiveEdges += edgeID
                }
            }
        }
        
        // recursive calls on descendants
        
        for descendantID in descendants
        {
            guard let descendant = self.node(for: descendantID) else { continue }
            
            idsOfTransitiveEdges += findTransitiveEdges(around: descendant,
                                                        reachedAncestors: ancestorsToConsider + node.id,
                                                        consideredAncestorsHash: &consideredAncestorsHash)
        }
        
        return idsOfTransitiveEdges
    }
}
