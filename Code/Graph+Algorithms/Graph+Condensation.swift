import SwiftyToolz
import OrderedCollections

public extension Graph
{
    /**
     Creates the acyclic condensation graph, contracting strongly connected components into single nodes.
     
     See <https://en.wikipedia.org/wiki/Strongly_connected_component>
     */
    func makeCondensation() -> CondensationGraph
    {
        let sccNodeSets = findStronglyConnectedComponents()
        
        // create SCCs and a hashmap from nodes to their SCCs
        var sccs = OrderedSet<StronglyConnectedComponent>()
        var sccHash = [Node: StronglyConnectedComponent]()
        
        for sccNodes in sccNodeSets
        {
            let scc = StronglyConnectedComponent(nodes: sccNodes)
            
            for sccNode in sccNodes
            {
                sccHash[sccNode] = scc
            }
            
            sccs.append(scc)
        }
        
        // create condensation graph
        var condensationGraph = CondensationGraph(values: sccs)
        
        // add condensation edges
        for edge in edges
        {
            
            guard let sourceSCC = sccHash[edge.source],
                    let targetSCC = sccHash[edge.target]
            else
            {
                fatalError("mising scc in hash map")
            }
            
            if sourceSCC !== targetSCC
            {
                condensationGraph.addEdge(from: sourceSCC, to: targetSCC)
            }
        }
        
        // return graph
        return condensationGraph
    }
    
    typealias CondensationGraph = Graph<StronglyConnectedComponent>
    typealias CondensationNode = GraphNode<StronglyConnectedComponent>
    typealias CondensationEdge = GraphEdge<StronglyConnectedComponent>
    
    class StronglyConnectedComponent: Identifiable, Hashable
    {
        public static func == (lhs: StronglyConnectedComponent,
                               rhs: StronglyConnectedComponent) -> Bool { lhs.id == rhs.id }
        
        public func hash(into hasher: inout Hasher) { hasher.combine(id) }
        
        init(nodes: Set<Node>)
        {
            self.nodes = nodes
        }
        
        public let nodes: Nodes
    }
}
