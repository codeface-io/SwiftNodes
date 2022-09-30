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
        let actualIncludedNodes = includedNodes ?? OrderedSet(nodesByID.values)
        
        let graphCopy = Graph(nodes: actualIncludedNodes)
        
        for originalEdge in includedEdges ?? Set(edgesByID.values)
        {
            graphCopy.addEdge(from: originalEdge.source, to: originalEdge.target)
        }
        
        return graphCopy
    }
}
