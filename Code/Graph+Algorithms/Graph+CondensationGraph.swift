import SwiftyToolz
import OrderedCollections

public extension Graph
{
    // TODO: this can be accelerated a bit by only working with- and returning Node IDs instead of Nodes. Nowhere here do we need neighbour IDs. First, findStronglyConnectedComponents() would need to be transformed in that manner ...
    
    /**
     Creates the acyclic [condensation graph](https://en.wikipedia.org/wiki/Strongly_connected_component) of the `Graph`
     
     The condensation graph is the graph in which the [strongly connected components](https://en.wikipedia.org/wiki/Strongly_connected_component) of the original graph have been collapsed into single nodes, so the resulting condensation graph is acyclic.
     */
    func makeCondensationGraph() -> CondensationGraph
    {
        // get SCCs
        let sccs = findStronglyConnectedComponents().map { StronglyConnectedComponent(nodes: $0) }
        
        // create hashmap from nodes to their SCCs
        var sccByNodeID = [Node.ID: StronglyConnectedComponent]()
        
        for scc in sccs
        {
            for node in scc.nodes
            {
                sccByNodeID[node.id] = scc
            }
        }
        
        // create condensation graph
        var condensationGraph = CondensationGraph(values: sccs)
        
        // add condensation edges
        for edgeID in edgesByID.keys
        {
            guard let originSCC = sccByNodeID[edgeID.originID],
                  let destinationSCC = sccByNodeID[edgeID.destinationID] else
            {
                fatalError("mising scc in hash map")
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
    
    // TODO: use NodeID as condensation node id type and require client to pass a closure for creating new ids of that type. use ids of contained node for StronglyConnectedComponents that contain only 1 node
    typealias CondensationGraph = Graph<StronglyConnectedComponent.ID, StronglyConnectedComponent>
    
    class StronglyConnectedComponent: Identifiable, Hashable
    {
        public static func == (lhs: StronglyConnectedComponent,
                               rhs: StronglyConnectedComponent) -> Bool { lhs.id == rhs.id }
        
        public func hash(into hasher: inout Hasher) { hasher.combine(id) }
        
        public let id: ID = .randomID()
        
        public typealias ID = String
        
        init(nodes: Nodes)
        {
            self.nodes = nodes
        }
        
        public let nodes: Nodes
    }
}
