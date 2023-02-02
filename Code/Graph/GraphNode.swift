import SwiftyToolz

extension GraphNode: Sendable where ID: Sendable, Value: Sendable {}
extension GraphNode: Equatable where Value: Equatable {}

/**
 Unique node of a ``Graph``, holds a value, can be connected to other nodes of the graph
 
 A `GraphNode` is `Identifiable` by its ``GraphNode/id`` of generic type `ID`.
 
 A `GraphNode` has caches maintained by its ``Graph`` that enable quick access to the node's neighbours, see ``GraphNode/ancestorIDs``, ``GraphNode/descendantIDs`` and related properties.
 
 A `Graph` creates, owns and manages its `GraphNode`s. You can not create a `GraphNode` or mutate the `GraphNode`s contained in a `Graph`, since the contained neighbour caches must always be consistent with the `Graph`'s edges.
 
 When inserting a `NodeValue` into a ``Graph``, the ``Graph`` determines the ID of the node containing that value by use of the closure passed to- (``Graph/init(values:edges:determineNodeIDForNewValue:)``) or implied by its initializer.
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
     The `Hashable` ID by which the node is `Identifiable`
     */
    public let id: ID
    
    /**
     The actual stored `Value`
     */
    public let value: Value
}
