import SwiftyToolz

public extension Graph
{
    /**
     Finds the minumum equivalent graph of an **acyclic** graph.
     
     🛑 If the graph is cyclic, this algorithm might hang or crash!
     
     See <https://en.wikipedia.org/wiki/Transitive_reduction>
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
        
        return copy(excludedEdges: nonEssentialEdges)
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
        
        let descendants = node.descendants
        
        for descendant in descendants
        {
            for ancestor in ancestorsToConsider
            {
                if let nonEssentialEdge = edge(from: ancestor, to: descendant)
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
