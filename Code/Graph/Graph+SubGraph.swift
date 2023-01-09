import OrderedCollections

public extension Graph
{
    func subGraph(nodes: OrderedSet<Node>) -> Graph where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        let nodeIDs = Set(nodes.map { $0.id })
        
        var subGraph = Graph(values: nodes.map { $0.value })
        
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
