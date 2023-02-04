import SwiftyToolz

public extension Graph
{
    /**
     Remove edges that not in the transitive reduction of the condensation graph
     
     Note that this will not remove any edges that are part of cycles (i.e. part of strongly connected components), as it only considers edges of the condensation graph. This is because it's [algorithmically](https://en.wikipedia.org/wiki/Feedback_arc_set#Hardness) as well as conceptually hard to decide which edges in cycles are "non-essential". We recommend dealing with cycles independently of using this function.
     */
    mutating func filterEssentialEdges()
    {
        filterEdges(findEssentialEdges())
    }
    
    /**
     Find edges that are in the minimum equivalent graph of the condensation graph
     
     Note that this includes all edges that are part of cycles (i.e. part of strongly connected components), as it only considers edges of the condensation graph. This is because it's [algorithmically](https://en.wikipedia.org/wiki/Feedback_arc_set#Hardness) as well as conceptually hard to decide which edges in cycles are "non-essential". We recommend dealing with cycles independently of using this function.
     */
    func findEssentialEdges() -> EdgeIDs
    {
        var idsOfEssentialEdges = EdgeIDs()
        
        // TODO: decomposing the graph into its components is probably legacy from before the algorithm extraction from Codeface ... this also seems to have no performance benefit here ... better just ensure makeCondensationGraph() (or find SCCs) and makeMinimumEquivalentGraph() work on disconnected graphs and then do this algorithm here on the whole graph in one go ...
        // for each component graph individually ...
        for component in findComponents()
        {
            let componentGraph = subGraph(nodeIDs: component)
            
            // TODO: Do we even need to create the MEG of the condensation graph here? AS SOON AS our algorithm to find all transitive edges (or inverted: the transitive reduction) correctly returns all edges that ARE NOT in cycles (even if the graph is cyclic) then we only need to filter out the edges which ARE in cycles for which we only need the SCCs ... this is about making the code more straight forward, we'll assess performance much later and based on measurement ...
            
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
            for edge in componentGraph.edges
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
        }
        
        return idsOfEssentialEdges
    }
}
