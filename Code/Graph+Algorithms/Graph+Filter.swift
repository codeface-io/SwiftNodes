public extension Graph
{
    func filteredEdges(_ isIncluded: EdgeIDs) -> Graph<NodeID, NodeValue>
    {
        var result = self
        result.filterEdges(isIncluded)
        return result
    }
    
    func filteredEdges(_ isIncluded: (Edge) throws -> Bool) rethrows -> Graph<NodeID, NodeValue>
    {
        var result = self
        try result.filterEdges(isIncluded)
        return result
    }
    
    mutating func filterEdges(_ isIncluded: EdgeIDs)
    {
        filterEdges { isIncluded.contains($0.id) }
    }
    
    mutating func filterEdges(_ isIncluded: (Edge) throws -> Bool) rethrows
    {
        try edges.forEach
        {
            if try !isIncluded($0)
            {
                removeEdge(with: $0.id)
            }
        }
    }
}
