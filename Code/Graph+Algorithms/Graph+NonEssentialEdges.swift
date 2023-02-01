import SwiftyToolz

public extension Graph
{
    /**
     Remove edges of the condensation graph that are not in its minimum equivalent graph
     
     Note that this will not remove any edges that are part of cycles (i.e. part of strongly connected components), as it only considers edges of the condensation graph. This is because it's [algorithmically](https://en.wikipedia.org/wiki/Feedback_arc_set#Hardness) as well as conceptually hard to decide which edges in cycles are "non-essential". We recommend dealing with cycles independently of using this function.
     */
    mutating func removeNonEssentialEdges()
    {
        findNonEssentialEdges().forEach { self.removeEdge(with: $0) }
    }
    
    /**
     Find edges of the condensation graph that are not in its minimum equivalent graph
     
     Note that this will not find any edges that are part of cycles (i.e. part of strongly connected components), as it only considers edges of the condensation graph. This is because it's [algorithmically](https://en.wikipedia.org/wiki/Feedback_arc_set#Hardness) as well as conceptually hard to decide which edges in cycles are "non-essential". We recommend dealing with cycles independently of using this function.
     */
    func findNonEssentialEdges() -> EdgeIDs
    {
        var idsOfNonEssentialEdges = EdgeIDs()
        
        // for each component graph individually ...
        for component in findComponents()
        {
            let componentGraph = subGraph(nodeIDs: component)
            
            // make condensation graph
            let condensationGraph = componentGraph.makeCondensationGraph()

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
            let minimumCondensationGraph = condensationGraph.makeMinimumEquivalentGraph()

            // for each original edge in the component graph ...
            for componentGraphEdge in componentGraph.edges
            {
                // skip this edge if it is within the same condensation node (within a strongly connected component)
                guard let sourceCondensationNodeID = condensationNodeIDByNodeID[componentGraphEdge.originID],
                      let targetCondensationNodeID = condensationNodeIDByNodeID[componentGraphEdge.destinationID]
                else
                {
                    log(error: "Nodes don't have their condensation node IDs set (but must have at this point)")
                    continue
                }

                if sourceCondensationNodeID == targetCondensationNodeID { continue }

                // the edge is essential if its equivalent is in the minimum equivalent condensation graph
                
                let edgeIsEssential = minimumCondensationGraph.contains(.init(sourceCondensationNodeID, targetCondensationNodeID))

                if !edgeIsEssential
                {
                    idsOfNonEssentialEdges += componentGraphEdge.id
                }
            }
        }
        
        return idsOfNonEssentialEdges
    }
}
