import SwiftyToolz

public extension Graph
{
    /**
     Finds the minumum equivalent graph of an **acyclic** graph.
     
     🛑 If the graph is cyclic, this algorithm might hang or crash!
     
     See <https://en.wikipedia.org/wiki/Transitive_reduction>
     */
    func makeMinimumEquivalentGraph() -> Graph<NodeValue>
    {
        var indirectReachabilities = Set<Edge>()
        var consideredAncestorsHash = [Node: Nodes]()
        
        for sourceNode in sources
        {
            // TODO: keep track of visited nodes within each traversal from a source and ignore already visited nodes so we can't get hung up in cycles
            
            let reachabilities = findIndirectReachabilities(around: sourceNode,
                                                            reachedAncestors: [],
                                                            consideredAncestorsHash: &consideredAncestorsHash)
            
            indirectReachabilities += reachabilities
        }
        
        return copy(excludedEdges: indirectReachabilities)
    }
    
    private func findIndirectReachabilities(around node: Node,
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
        
        var indirectReachabilities = Set<Edge>()
        
        // base case: add edges from all reached ancestors to all reachable neighbours of node
        
        let descendants = node.descendants
        
        for descendant in descendants
        {
            for ancestor in ancestorsToConsider
            {
                indirectReachabilities += Edge(from: ancestor, to: descendant)
            }
        }
        
        // recursive calls on descendants
        
        for descendant in descendants
        {
            indirectReachabilities += findIndirectReachabilities(around: descendant,
                                                                 reachedAncestors: ancestorsToConsider + node,
                                                                 consideredAncestorsHash: &consideredAncestorsHash)
        }
        
        return indirectReachabilities
    }
}
