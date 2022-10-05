import SwiftyToolz
import OrderedCollections

public extension Graph
{
    /**
     Creates the acyclic condensation graph, contracting strongly connected components into single nodes.
     
     See <https://en.wikipedia.org/wiki/Strongly_connected_component>
     */
    func makeCondensationGraph() -> CondensationGraph
    {
        // get SCCs
        let sccs = findStronglyConnectedComponents().map { StronglyConnectedComponent(nodes: $0) }
        
        // create hashmap from nodes to their SCCs
        var sccHash = [Node: StronglyConnectedComponent]()
        
        for scc in sccs
        {
            for sccNode in scc.nodes
            {
                sccHash[sccNode] = scc
            }
        }
        
        // create condensation graph
        let condensationNodes = sccs.map { CondensationNode(id: $0.id, value: $0) }
        let condensationGraph = CondensationGraph(nodes: OrderedSet(condensationNodes)) { $0.id }
        
        // add condensation edges
        for edge in edgesByID.values
        {
            guard let sourceSCC = sccHash[edge.source], let targetSCC = sccHash[edge.target] else
            {
                fatalError("mising scc in hash map")
            }
            
            if sourceSCC !== targetSCC
            {
                condensationGraph.addEdge(from: sourceSCC.id, to: targetSCC.id)
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
