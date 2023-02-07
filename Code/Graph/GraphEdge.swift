import SwiftyToolz

extension GraphEdge: Sendable where NodeID: Sendable, Weight: Sendable {}
extension GraphEdge.ID: Sendable where NodeID: Sendable {}

extension GraphEdge: Codable where NodeID: Codable, Weight: Codable {}
extension GraphEdge.ID: Codable where NodeID: Codable {}

/**
 Directed connection of two ``GraphNode``s in a ``Graph``
 
 A `GraphEdge` points from an origin- to a destination node and therefor has an ``GraphEdge/originID`` and a ``GraphEdge/destinationID``.
 
 A `GraphEdge` is `Identifiable` by its ``GraphEdge/id-swift.property``, which is a combination of ``GraphEdge/originID`` and ``GraphEdge/destinationID``.
 */
public struct GraphEdge<NodeID: Hashable, Weight: Numeric>: Identifiable, Equatable
{
    /**
     A shorthand for the edge's full generic type name `GraphEdge<NodeID>`
     */
    public typealias Edge = GraphEdge<NodeID, Weight>
    
    // MARK: - Identity
    
    /**
     The edge's `ID` combines the ``GraphNode/id``s of ``GraphEdge/originID`` and ``GraphEdge/destinationID``
     */
    public var id: ID { ID(originID, destinationID) }
    
    /**
     An edge's `ID` combines the ``GraphNode/id``s of its ``GraphEdge/originID`` and ``GraphEdge/destinationID``
     */
    public struct ID: Hashable
    {
        internal init(_ originID: NodeID, _ destinationID: NodeID)
        {
            self.originID = originID
            self.destinationID = destinationID
        }
        
        public let originID: NodeID
        public let destinationID: NodeID
    }
    
    // MARK: - Basics
    
    /// Create a ``GraphEdge``, for instance to pass it to a ``Graph`` initializer.
    public init(from originID: NodeID,
                to destinationID: NodeID,
                weight: Weight = 1)
    {
        self.originID = originID
        self.destinationID = destinationID
        
        self.weight = weight
    }
    
    /**
     The edge weight.
     
     If you don't need edge weights and want to save memory, you could specify `UInt8` (a.k.a. Byte) as the edge weight type, so each edge would require just one Byte instead of for example four or 8 Bytes for other numeric types.
     */
    public internal(set) var weight: Weight
    
    /**
     The origin ``GraphNode/id`` at which the edge starts / from which it goes out
     */
    public let originID: NodeID
    
    /**
     The destination ``GraphNode/id`` at which the edge ends / to which it goes in
     */
    public let destinationID: NodeID
}
