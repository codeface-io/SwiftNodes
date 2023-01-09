import SwiftyToolz

/**
 Directed connection of two ``GraphNode``s in a ``Graph``
 
 A `GraphEdge` has a direction and goes from its ``GraphEdge/origin`` to its ``GraphEdge/destination``
 
 A `GraphEdge` is `Identifiable` by its ``GraphEdge/id-swift.property``, which is a combination of the ``GraphNode/id``s of ``GraphEdge/origin`` and ``GraphEdge/destination``.
 
 Edges are owned and managed by a ``Graph``. You create, query and destroy them via a given ``Graph``:
 
  - ``Graph/addEdge(from:to:count:)-mz60``
  - ``Graph/addEdge(from:to:count:)-8wg9h``
  - ``Graph/edge(from:to:)-y9tk``
  - ``Graph/edge(from:to:)-7vu5h``
  - ``Graph/edgesByID``
  - ``Graph/edges``
  - ``Graph/remove(_:)``
  - ``Graph/removeEdge(with:)``
  - ``Graph/removeEdge(from:to:)-55efs``
  - ``Graph/removeEdge(from:to:)-1gqeh``
 */
public struct GraphEdge<NodeID: Hashable, NodeValue>: Identifiable, Hashable, Sendable
    where NodeID: Sendable, NodeValue: Sendable
{
    // MARK: - Hashability
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    public static func == (lhs: Edge, rhs: Edge) -> Bool { lhs.id == rhs.id }
    
    /**
     A shorthand for the edge's full generic type name `GraphEdge<NodeID, NodeValue>`
     */
    public typealias Edge = GraphEdge<NodeID, NodeValue>
    
    // MARK: - Identity
    
    /**
     The edge's `ID` combines the ``GraphNode/id``s of ``GraphEdge/origin`` and ``GraphEdge/destination``
     */
    public var id: ID { ID(originID, destinationID) }
    
    /**
     An edge's `ID` combines the ``GraphNode/id``s of its ``GraphEdge/origin`` and ``GraphEdge/destination``
     */
    public struct ID: Hashable, Sendable
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
    
    internal init(from originID: NodeID, to destinationID: NodeID, count: Int = 1)
    {
        self.originID = originID
        self.destinationID = destinationID
        
        self.count = count
    }
    
    /**
     A kind of edge weight. Indicates how often the edge was "added" to its graph.
     
     The count to "add" can be specified when adding an edge to a graph, see ``Graph/addEdge(from:to:count:)-mz60`` and ``Graph/addEdge(from:to:count:)-8wg9h``. By default, adding the edge the first time sets its count to 1, and every time it gets added again adds 1 to its `count`.
     */
    public internal(set) var count: Int
    
    /**
     The origin ``GraphNode/id`` at which the edge starts / from which it goes out
     */
    public let originID: NodeID
    
    /**
     The destination ``GraphNode/id`` at which the edge ends / to which it goes in
     */
    public let destinationID: NodeID
    
    /**
     A shorthand for the `origin`- and `destination` type `GraphNode<NodeID, NodeValue>`
     */
    public typealias Node = GraphNode<NodeID, NodeValue>
}
