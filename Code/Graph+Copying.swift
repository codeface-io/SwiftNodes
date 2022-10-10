import SwiftyToolz
import OrderedCollections

extension Graph
{
    public func copy(includedNodes: [Node]) -> Graph<NodeID, NodeValue>
    {
        copy(includedNodes: OrderedSet(includedNodes))
    }
    
    public func copy(excludedEdges: Set<Edge>) -> Graph<NodeID, NodeValue>
    {
        copy(includedEdges: Set(edgesByID.values) - excludedEdges)
    }
    
    /// Make a copy of (a subset of) the graph
    public func copy(includedNodes: OrderedSet<Node>? = nil,
                     includedEdges: Set<Edge>? = nil) -> Graph<NodeID, NodeValue>
    {
        let myNodes = OrderedSet(nodesByID.values)
        
        if !(includedNodes?.isSubset(of: myNodes) ?? true)
        {
            log(warning: "Some nodes to include in the Graph copy are not in the graph.")
        }
        
        let actualIncludedNodes = includedNodes ?? myNodes
        let copiesOfIncludedNodes = actualIncludedNodes.map { Node(id: $0.id, value: $0.value) }
        
        let graphCopy = Graph(nodes: OrderedSet(copiesOfIncludedNodes),
                              makeNodeIDForValue: self.makeNodeIDForValue)
        
        for originalEdge in includedEdges ?? Set(edgesByID.values)
        {
            guard graphCopy.contains(originalEdge.origin.id),
                  graphCopy.contains(originalEdge.destination.id) else { continue }
            
            graphCopy.addEdge(from: originalEdge.origin.id,
                              to: originalEdge.destination.id,
                              count: originalEdge.count)
        }
        
        return graphCopy
    }
}
