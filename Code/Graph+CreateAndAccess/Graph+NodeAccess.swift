public extension Graph
{
    /// Remove the node with the given ID also removing its in- and outgoing edges
    @discardableResult
    mutating func removeNode(with nodeID: NodeID) -> Node?
    {
        guard let node = nodesByID.removeValue(forKey: nodeID) else
        {
            return nil
        }
        
        for ancestorID in node.ancestorIDs
        {
            removeEdge(with: .init(ancestorID, nodeID))
        }
        
        for descendantID in node.descendantIDs
        {
            removeEdge(with: .init(nodeID, descendantID))
        }
        
        return node
    }
    
    /**
     All source nodes of the `Graph`, see ``GraphNode/isSource``
     */
    var sources: some Collection<Node>
    {
        nodesByID.values.filter { $0.isSource }
    }
    
    /**
     All sink nodes of the `Graph`, see ``GraphNode/isSink``
     */
    var sinks: some Collection<Node>
    {
        nodesByID.values.filter { $0.isSink }
    }
    
    /**
     Whether the `Graph` contains a ``GraphNode`` with the given ``GraphNode/id``
     */
    func contains(_ nodeID: NodeID) -> Bool
    {
        nodesByID.keys.contains(nodeID)
    }
    
    /**
     ``GraphNode`` with the given ``GraphNode/id`` if one exists, otherwise `nil`
     */
    func node(with id: NodeID) -> Node?
    {
        nodesByID[id]
    }
    
    /**
     All ``GraphNode``s of the `Graph`
     */
    var nodes: some Collection<Node>
    {
        nodesByID.values
    }
    
    /**
     The ``GraphNode/id``s of all ``GraphNode``s of the `Graph`
     */
    var nodeIDs: some Collection<NodeID>
    {
        nodesByID.keys
    }
}
