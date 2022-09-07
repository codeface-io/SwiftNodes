import SwiftyToolz
import OrderedCollections

extension Graph
{
    public func copy(includedValues: [NodeValue]) -> Graph<NodeValue>
    {
        copy(includedValues: OrderedSet(includedValues))
    }
    
    public func copy(excludedEdges: Set<Edge>) -> Graph<NodeValue>
    {
        copy(includedEdges: Set(edgesByID.values) - excludedEdges)
    }
    
    /// Make a copy of (a subset of) the graph
    public func copy(includedValues: OrderedSet<NodeValue>? = nil,
                     includedEdges: Set<Edge>? = nil) -> Graph<NodeValue>
    {
        let actualIncludedValues = includedValues ?? OrderedSet(nodes.map { $0.value } )
        var graphCopy = Graph(values: actualIncludedValues)
        
        for originalEdge in includedEdges ?? Set(edgesByID.values)
        {
            graphCopy.addEdge(from: originalEdge.source.value, to: originalEdge.target.value)
        }
        
        return graphCopy
    }
}
