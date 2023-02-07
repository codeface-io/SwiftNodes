import SwiftyToolz

public extension Graph
{
    /**
     Removes the corresponding ``GraphEdge``, see ``Graph/removeEdge(with:)``
     */
    @discardableResult
    mutating func removeEdge(from originID: NodeID,
                             to destinationID: NodeID) -> Edge?
    {
        removeEdge(with: .init(originID, destinationID))
    }
    
    /**
     Removes the ``GraphEdge`` with the given ID, also removing it from node neighbour caches
     */
    @discardableResult
    mutating func removeEdge(with id: Edge.ID) -> Edge?
    {
        // remove from node caches
        nodesByID[id.originID]?.descendantIDs -= id.destinationID
        nodesByID[id.destinationID]?.ancestorIDs -= id.originID
        
        // remove edge itself
        return edgesByID.removeValue(forKey: id)
    }
    
    /**
     Add to the count of the edge with the given ID, create the edge if necessary
     
     - Returns: The new count of the edge with the given ID
     */
    @discardableResult
    mutating func add(count: Int, toEdgeWith id: Edge.ID) -> Int
    {
        if let existingCount = edgesByID[id]?.count
        {
            edgesByID[id]?.count += count
            
            return existingCount + count
        }
        else
        {
            insertEdge(from: id.originID,
                       to: id.destinationID,
                       count: count)
            
            return count
        }
    }
    
    @discardableResult
    mutating func insertEdge(from originID: NodeID,
                             to destinationID: NodeID,
                             count: Int = 1) -> Edge
    {
        let edge = Edge(from: originID, to: destinationID, count: count)
        insert(edge)
        return edge
    }
    
    mutating func insert(_ edge: Edge)
    {
        if !contains(edge.id)
        {
            // update node caches because edge does not exist yet
            nodesByID[edge.originID]?.descendantIDs += edge.destinationID
            nodesByID[edge.destinationID]?.ancestorIDs += edge.originID
        }
        
        edgesByID.insert(edge)
    }
    
    /**
     The ``GraphEdge`` between the corresponding nodes if it exists, otherwise `nil`
     */
    func edge(from originID: NodeID, to destinationID: NodeID) -> Edge?
    {
        edge(with: .init(originID, destinationID))
    }
    
    /**
     The ``GraphEdge`` with the given ID if the edge exists, otherwise `nil`
     */
    func edge(with id: Edge.ID) -> Edge?
    {
        edgesByID[id]
    }
    
    /**
     Whether the `Graph` contains a ``GraphEdge`` with the given ``GraphEdge/id-swift.property``
     */
    func contains(_ edgeID: Edge.ID) -> Bool
    {
        edgesByID.keys.contains(edgeID)
    }
    
    /**
     All ``GraphEdge``s of the `Graph`
     */
    var edges: some Collection<Edge>
    {
        edgesByID.values
    }
    
    /**
     All ``GraphEdge/id-swift.property``s of the ``GraphEdge``s of the `Graph`
     */
    var edgeIDs: some Collection<Edge.ID>
    {
        edgesByID.keys
    }
}
