import SwiftyToolz

public extension Graph
{
    /**
     Graph with only the edges of the transitive reduction of the condensation graph
     
     Note that this will not remove any edges that are part of cycles (i.e. part of strongly connected components), since only considers edges of the condensation graph can be "non-essential". This is because it's [algorithmically](https://en.wikipedia.org/wiki/Feedback_arc_set#Hardness) as well as conceptually hard to decide which edges in cycles are "non-essential". We recommend dealing with cycles independently of using this function.
     */
    func filteredEssentialEdges() -> Graph<NodeID, NodeValue>
    {
        var result = self
        result.filterEssentialEdges()
        return result
    }
    
    /**
     Remove edges that are not in the transitive reduction of the condensation graph
     
     Note that this will not remove any edges that are part of cycles (i.e. part of strongly connected components), since only considers edges of the condensation graph can be "non-essential". This is because it's [algorithmically](https://en.wikipedia.org/wiki/Feedback_arc_set#Hardness) as well as conceptually hard to decide which edges in cycles are "non-essential". We recommend dealing with cycles independently of using this function.
     */
    mutating func filterEssentialEdges()
    {
        filterEdges(findEssentialEdges())
    }
    
    /**
     Find edges that are in the minimum equivalent graph of the condensation graph
     
     Note that this includes all edges that are part of cycles (i.e. part of strongly connected components), since only edges of the condensation graph can be "non-essential". This is because it's [algorithmically](https://en.wikipedia.org/wiki/Feedback_arc_set#Hardness) as well as conceptually hard to decide which edges in cycles are "non-essential". We recommend dealing with cycles independently of using this function.
     */
    func findEssentialEdges() -> EdgeIDs
    {
        var idsOfEssentialEdges = EdgeIDs()
        
        // make condensation graph
        let condensationGraph = makeCondensationGraph()
        
        // remember in which condensation node each original node is contained
        var condensationNodeIDByNodeID = [NodeID: StronglyConnectedComponent.ID]()
        
        for condensationNode in condensationGraph.nodes
        {
            for node in condensationNode.value.nodeIDs
            {
                condensationNodeIDByNodeID[node] = condensationNode.id
            }
        }
        
        // make minimum equivalent condensation graph
        let minimumCondensationGraph = condensationGraph.filteredTransitiveReduction()
        
        // for each original edge in the component graph ...
        for edge in edges
        {
            guard let originCondensationNodeID = condensationNodeIDByNodeID[edge.originID],
                  let destinationCondensationNodeID = condensationNodeIDByNodeID[edge.destinationID]
            else
            {
                log(error: "Nodes don't have their condensation node IDs set (but must have at this point)")
                continue
            }
            
            // add this edge if it is within the same condensation node (within a strongly connected component and thereby within a cycle)
            
            if originCondensationNodeID == destinationCondensationNodeID
            {
                idsOfEssentialEdges += edge.id
                continue
            }
            
            // the non-cyclic edge is essential if its equivalent is in the minimum equivalent condensation graph
            
            let condensationEdgeID = CondensationEdge.ID(originCondensationNodeID,
                                                         destinationCondensationNodeID)
            
            let edgeIsEssential = minimumCondensationGraph.contains(condensationEdgeID)
            
            if edgeIsEssential
            {
                idsOfEssentialEdges += edge.id
            }
        }
        
        return idsOfEssentialEdges
    }
}
