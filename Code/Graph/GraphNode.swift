import SwiftyToolz

extension GraphNode: Sendable where ID: Sendable, Value: Sendable {}
extension GraphNode: Equatable where Value: Equatable {}

/**
 Unique node of a ``Graph``, holds a value, can be connected to other nodes of the graph
 
 A `GraphNode` is `Identifiable` by its ``GraphNode/id`` of generic type `ID`.
 
 You typically create `GraphNode`s by inserting `NodeValue`s into a ``Graph``, whereby the ``Graph`` generates the IDs for new nodes according to the closure passed to- (``Graph/init(nodes:makeNodeIDForValue:)``) or implied by its initializer.
 
 You may also create `GraphNode`s independent of a ``Graph`` in order to create a new ``Graph`` with them, see ``GraphNode/init(id:value:)`` and ``Graph/init(nodes:makeNodeIDForValue:)``.
 
 A `GraphNode` has caches maintained by its ``Graph`` that enable quick access to the node's neighbours, see ``GraphNode/ancestorIDs``, ``GraphNode/descendantIDs`` and related properties.
 */
public struct GraphNode<ID: Hashable, Value>: Identifiable
{
    // MARK: - Caches for Accessing Neighbours Quickly
    
    /**
     Indicates whether the node has no descendants (no outgoing edges)
     */
    public var isSink: Bool { descendantIDs.isEmpty }
    
    /**
     Indicates whether the node has no ancestors (no ingoing edges)
     */
    public var isSource: Bool { ancestorIDs.isEmpty }
    
    /**
     The node's neighbours (nodes connected via in- or outgoing edges)
     */
    public var neighbourIDs: Set<ID> { ancestorIDs + descendantIDs }
    
    /**
     The node's ancestors (nodes connected via ingoing edges)
     */
    public internal(set) var ancestorIDs = Set<ID>()
    
    /**
     The node's descendants (nodes connected via outgoing edges)
     */
    public internal(set) var descendantIDs = Set<ID>()
    
    /**
     A shorthand for the node's full generic type name `GraphNode<ID, Value>`
     */
    public typealias Node = GraphNode<ID, Value>
    
    // MARK: - Identity & Value
    
    /**
     Create a `GraphNode` as input for a new ``Graph``, see ``Graph/init(nodes:makeNodeIDForValue:)``
     */
    public init(id: ID, value: Value)
    {
        self.id = id
        self.value = value
    }
    
    /**
     The `ID: Hashable` by which the node is `Identifiable`
     */
    public let id: ID
    
    /**
     The actual stored `Value`
     */
    public let value: Value
}
