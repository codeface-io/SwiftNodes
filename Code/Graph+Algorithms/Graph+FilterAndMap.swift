public extension Graph
{
    // MARK: - Value Mapper
    
    func map<MappedValue>(_ transform: (NodeValue) throws -> MappedValue) rethrows -> Graph<NodeID, MappedValue, EdgeWeight>
    {
        .init(idValuePairs: try nodes.map { ($0.id, try transform($0.value)) },
              edges: edges)
    }
    
    // MARK: - Edge Filters
    
    func filteredEdges(_ isIncluded: EdgeIDs) -> Self
    {
        var result = self
        result.filterEdges(isIncluded)
        return result
    }
    
    mutating func filterEdges(_ isIncluded: EdgeIDs)
    {
        filterEdges { isIncluded.contains($0.id) }
    }
    
    func filteredEdges(_ isIncluded: (Edge) throws -> Bool) rethrows -> Self
    {
        var result = self
        try result.filterEdges(isIncluded)
        return result
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
    
    // MARK: - Value Filters
    
    func filtered(_ isIncluded: (NodeValue) throws -> Bool) rethrows -> Self
    {
        var result = self
        try result.filter(isIncluded)
        return result
    }
    
    mutating func filter(_ isIncluded: (NodeValue) throws -> Bool) rethrows
    {
        try filterNodes { try isIncluded($0.value) }
    }
    
    // MARK: - Node Filters
    
    func filteredNodes(_ isIncluded: NodeIDs) -> Self
    {
        var result = self
        result.filterNodes(isIncluded)
        return result
    }
    
    mutating func filterNodes(_ isIncluded: NodeIDs)
    {
        filterNodes { isIncluded.contains($0.id) }
    }
    
    func filteredNodes(_ isIncluded: (Node) throws -> Bool) rethrows -> Self
    {
        var result = self
        try result.filterNodes(isIncluded)
        return result
    }
    
    mutating func filterNodes(_ isIncluded: (Node) throws -> Bool) rethrows
    {
        try nodes.forEach
        {
            if try !isIncluded($0)
            {
                removeNode(with: $0.id)
            }
        }
    }
}
