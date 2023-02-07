import SwiftyToolz

public extension Graph
{
    /**
     The [minumum equivalent graph](https://en.wikipedia.org/wiki/Transitive_reduction) of an **acyclic** `Graph`
     
     🛑 This only works on acyclic graphs and might even hang or crash on cyclic ones!
     */
    func filteredTransitiveReduction() -> Graph<NodeID, NodeValue>
    {
        var minimumEquivalentGraph = self
        minimumEquivalentGraph.filterTransitiveReduction()
        return minimumEquivalentGraph
    }
    
    /**
     Filter an **acyclic** `Graph` down to its [minumum equivalent graph](https://en.wikipedia.org/wiki/Transitive_reduction)
     
     🛑 This only works on acyclic graphs and might even hang or crash on cyclic ones!
     */
    mutating func filterTransitiveReduction()
    {
        let transitiveEdges = findTransitiveEdges()
        filterEdges { !transitiveEdges.contains($0.id) }
    }
    
    /**
     Edges that are *not* in the [minumum equivalent graph](https://en.wikipedia.org/wiki/Transitive_reduction) of an **acyclic** `Graph`
     
     🛑 This only works on acyclic graphs and might even hang or crash on cyclic ones!
     */
    func findTransitiveEdges() -> EdgeIDs
    {
        var idOfTransitiveEdges = EdgeIDs() // or "shortcuts" of longer paths; or "implied" edges
        
        var consideredAncestorsHash = [NodeID: NodeIDs]()
        
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
        // to make this not hang in cycles it might be enough to just ensure that node is not in reachedAncestors ...
        
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
            guard let descendant = self.node(with: descendantID) else { continue }
            
            idsOfTransitiveEdges += findTransitiveEdges(around: descendant,
                                                        reachedAncestors: ancestorsToConsider + node.id,
                                                        consideredAncestorsHash: &consideredAncestorsHash)
        }
        
        return idsOfTransitiveEdges
    }
}
