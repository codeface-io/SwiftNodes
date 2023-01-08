import SwiftyToolz
import OrderedCollections

public extension Graph
{
    /**
     Creates the acyclic [condensation graph](https://en.wikipedia.org/wiki/Strongly_connected_component) of the `Graph`
     
     The condensation graph is the graph in which the [strongly connected components](https://en.wikipedia.org/wiki/Strongly_connected_component) of the original graph have been collapsed into single nodes, so the resulting condensation graph is acyclic.
     */
    func makeCondensationGraph() -> CondensationGraph
    {
        // get SCCs
        let sccs = findStronglyConnectedComponents().map { StronglyConnectedComponent(nodes: $0) }
        
        // create hashmap from nodes to their SCCs
        var sccHash = [Node.ID: StronglyConnectedComponent]()
        
        for scc in sccs
        {
            for sccNode in scc.nodes
            {
                sccHash[sccNode.id] = scc
            }
        }
        
        // create condensation graph
        let condensationNodes = sccs.map { CondensationNode(id: $0.id, value: $0) }
        var condensationGraph = CondensationGraph(nodes: OrderedSet(condensationNodes)) { $0.id }
        
        // add condensation edges
        for edge in edgesByID.values
        {
            guard let originSCC = sccHash[edge.originID],
                  let destinationSCC = sccHash[edge.destinationID] else
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
    typealias CondensationGraph = Graph<String, StronglyConnectedComponent>
    
    class StronglyConnectedComponent: Identifiable, Hashable
    {
        public static func == (lhs: StronglyConnectedComponent,
                               rhs: StronglyConnectedComponent) -> Bool { lhs.id == rhs.id }
        
        public func hash(into hasher: inout Hasher) { hasher.combine(id) }
        
        public let id: String = .randomID()
        
        init(nodes: Set<Node>)
        {
            self.nodes = nodes
        }
        
        public let nodes: Nodes
    }
}
