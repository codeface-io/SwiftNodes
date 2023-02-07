import SwiftyToolz

extension Graph.StronglyConnectedComponent: Sendable where NodeID: Sendable {}

public extension Graph
{
    /**
     Creates the acyclic [condensation graph](https://en.wikipedia.org/wiki/Strongly_connected_component) of the `Graph`
     
     The condensation graph is the graph in which the [strongly connected components](https://en.wikipedia.org/wiki/Strongly_connected_component) of the original graph have been collapsed into single nodes, so the resulting condensation graph is acyclic.
     */
    func makeCondensationGraph() -> CondensationGraph
    {
        // get SCCs
        let sccs = findStronglyConnectedComponents().map
        {
            StronglyConnectedComponent(nodeIDs: $0)
        }
        
        // create hashmap from node IDs to the containing SCCs
        var sccByNodeID = [Node.ID: StronglyConnectedComponent]()
        
        for scc in sccs
        {
            for nodeID in scc.nodeIDs
            {
                sccByNodeID[nodeID] = scc
            }
        }
        
        // create condensation graph
        var condensationGraph = CondensationGraph(values: sccs)
        
        // add condensation edges
        for edgeID in edgeIDs
        {
            guard let originSCC = sccByNodeID[edgeID.originID],
                  let destinationSCC = sccByNodeID[edgeID.destinationID] else
            {
                log(error: "mising scc in hash map")
                continue
            }
            
            if originSCC.id != destinationSCC.id
            {
                condensationGraph.insert(.init(from: originSCC.id,
                                               to: destinationSCC.id))
            }
        }
        
        // return graph
        return condensationGraph
    }
    
    typealias CondensationNode = CondensationGraph.Node
    typealias CondensationEdge = CondensationGraph.Edge
    
    typealias CondensationGraph = Graph<StronglyConnectedComponent.ID, StronglyConnectedComponent>
    
    struct StronglyConnectedComponent: Identifiable, Hashable
    {
        public var id: ID { nodeIDs }
        
        public typealias ID = NodeIDs
        
        init(nodeIDs: NodeIDs)
        {
            self.nodeIDs = nodeIDs
        }
        
        public let nodeIDs: NodeIDs
    }
}
