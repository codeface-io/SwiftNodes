import SwiftyToolz
import OrderedCollections


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
            StronglyConnectedComponent(nodes: $0)
        }
        
        // create hashmap from nodes to their SCCs
        var sccByNodeID = [Node.ID: StronglyConnectedComponent]()
        
        for scc in sccs
        {
            for node in scc.nodes
            {
                sccByNodeID[node] = scc
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
            
            if originSCC !== destinationSCC
            {
                condensationGraph.addEdge(from: originSCC.id,
                                          to: destinationSCC.id)
            }
        }
        
        // return graph
        return condensationGraph
    }
    
    typealias CondensationNode = CondensationGraph.Node
    typealias CondensationEdge = CondensationGraph.Edge
    
    typealias CondensationGraph = Graph<StronglyConnectedComponent.ID, StronglyConnectedComponent>
    
    final class StronglyConnectedComponent: Identifiable, Hashable
    {
        public static func == (lhs: StronglyConnectedComponent,
                               rhs: StronglyConnectedComponent) -> Bool { lhs.id == rhs.id }
        
        public func hash(into hasher: inout Hasher) { hasher.combine(id) }
        
        // TODO: use NodeID as condensation node id type and derive id from contained nodes (requires that there is at least one contained node)
        public let id: ID = .randomID()
        
        public typealias ID = String
        
        init(nodes: NodeIDs)
        {
            self.nodes = nodes
        }
        
        public let nodes: NodeIDs
    }
}
