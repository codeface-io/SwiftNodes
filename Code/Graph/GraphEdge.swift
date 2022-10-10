import SwiftyToolz

/**
 Directed connection of two ``GraphNode``s in a ``Graph``
 
 A `GraphEdge` has a direction and goes from its ``GraphEdge/source`` to its ``GraphEdge/target``
 
 A `GraphEdge` is `Identifiable` by its ``GraphEdge/id-swift.property``, which is a combination of the ``GraphNode/id``s of ``GraphEdge/source`` and ``GraphEdge/target``.
 
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
public class GraphEdge<NodeID: Hashable, NodeValue>: Identifiable, Hashable
{
    // MARK: - Hashability
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    public static func == (lhs: Edge, rhs: Edge) -> Bool { lhs === rhs }
    
    /**
     A shorthand for the edge's full generic type name `GraphEdge<NodeID, NodeValue>`
     */
    public typealias Edge = GraphEdge<NodeID, NodeValue>
    
    // MARK: - Identity
    
    /**
     The edge's `ID` combines the ``GraphNode/id``s of ``GraphEdge/source`` and ``GraphEdge/target``
     */
    public var id: ID { ID(source, target) }
    
    /**
     An edge's `ID` combines the ``GraphNode/id``s of its ``GraphEdge/source`` and ``GraphEdge/target``
     */
    public struct ID: Hashable
    {   
        internal init(_ source: Node, _ target: Node)
        {
            self.init(source.id, target.id)
        }
        
        internal init(_ sourceID: NodeID, _ targetID: NodeID)
        {
            self.sourceID = sourceID
            self.targetID = targetID
        }
        
        public let sourceID: NodeID
        public let targetID: NodeID
    }
    
    // MARK: - Basics
    
    internal init(from source: Node, to target: Node, count: Int = 1)
    {
        self.source = source
        self.target = target
        
        self.count = count
    }
    
    /**
     A kind of edge weight. Indicates how often the edge was "added" to its graph.
     
     The count to "add" can be specified when adding an edge to a graph, see ``Graph/addEdge(from:to:count:)-mz60`` and ``Graph/addEdge(from:to:count:)-8wg9h``. By default, adding the edge the first time sets its count to 1, and every time it gets added again adds 1 to its `count`.
     */
    public internal(set) var count: Int
    
    /**
     The origin ``GraphNode`` at which the edge starts / goes out
     */
    public let source: Node
    
    /**
     The destination ``GraphNode`` at which the edge ends / goes in
     */
    public let target: Node
    
    /**
     A shorthand for the `source`- and `target` type `GraphNode<NodeID, NodeValue>`
     */
    public typealias Node = GraphNode<NodeID, NodeValue>
}
