public extension Graph
{
    func subGraph(nodeIDs: NodeIDs) -> Graph
    {
        var subGraph = Graph(values: nodeIDs.compactMap { nodesByID[$0]?.value },
                             makeNodeIDForValue: determineNodeIDForNewValue)
        
        for edge in edges
        {
            if nodeIDs.contains(edge.originID) && nodeIDs.contains(edge.destinationID)
            {
                subGraph.addEdge(from: edge.originID,
                                 to: edge.destinationID,
                                 count: edge.count)
            }
        }
        
        return subGraph
    }
}
