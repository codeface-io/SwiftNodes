import SwiftyToolz

/**
 Unique node of a ``Graph``, holds a value, can be connected to other nodes of the graph
 
 A `GraphNode` is `Identifiable` by its ``GraphNode/id`` of generic type `ID`.
 
 You typically create `GraphNode`s by inserting `NodeValue`s into a ``Graph``, whereby the ``Graph`` generates the IDs for new nodes according to the closure passed to- (``Graph/init(nodes:makeNodeIDForValue:)``) or implied by its initializer.
 
 You may also create `GraphNode`s independent of a ``Graph`` in order to create a new ``Graph`` with them, see ``GraphNode/init(id:value:)`` and ``Graph/init(nodes:makeNodeIDForValue:)``.
 
 A `GraphNode` has caches maintained by its ``Graph`` that enable quick access to the node's neighbours, see ``GraphNode/ancestors``, ``GraphNode/descendants`` and related properties.
 
 A `GraphNode` can be marked with a ``GraphNode/Marking-swift.class``, which supports optimal graph algorithm performance, as algorithms don't need to remember and hash nodes to "mark" them but can rather mark them directly.
 */
public class GraphNode<ID: Hashable, Value>: Identifiable, Hashable
{
    // MARK: - Marking for Algorithms
    
    /**
     Supports optimal algorithm performance by allowing algorithms to mark nodes directly
     
     Algorithms don't need to remember and hash nodes to "mark" them but can rather mark them directly via this property.
     
     See ``GraphNode/Marking-swift.class``, ``GraphNode/mark(with:)``, ``GraphNode/isMarked``, ``Graph/setNodeMarkings(to:)`` and ``Graph/unmarkNodes()``.
     */
    public var marking: Marking?
    
    /**
     A general-purpose node marking to support optimal graph algorithm performance
     
     Algorithms don't need to remember and then hash nodes to "mark" them but can rather mark them directly via their ``GraphNode/marking-swift.property`` property.
     
     See , ``GraphNode/mark(with:)``, ``GraphNode/isMarked``, ``Graph/setNodeMarkings(to:)`` and ``Graph/unmarkNodes()``.
     
     You can use a ``GraphNode/Marking-swift.class/zero`` `Marking` to generally mark a ``GraphNode``, see ``GraphNode/mark(with:)``. But you can also leverage the `Int` and `Bool` properties on `Marking` when your algorithm needs to mark nodes in multiple different ways.
     */
    public class Marking
    {
        public init(number1: Int = 0, number2: Int = 0,
                    flag1: Bool = false, flag2: Bool = false)
        {
            self.number1 = number1
            self.number2 = number2
            self.flag1 = flag1
            self.flag2 = flag2
        }
        
        /**
         General purpose helper number that graph algorithms can write to ``GraphNode/marking-swift.property``
         */
        var number1, number2: Int
        
        /**
         General purpose helper flag that graph algorithms can write to ``GraphNode/marking-swift.property``
         */
        var flag1, flag2: Bool
    }
    
    // MARK: - Caches for Accessing Neighbours Quickly
    
    /**
     Indicates whether the node has no descendants (no outgoing edges)
     */
    public var isSink: Bool { descendants.isEmpty }
    
    /**
     Indicates whether the node has no ancestors (no ingoing edges)
     */
    public var isSource: Bool { ancestors.isEmpty }
    
    /**
     The node's neighbours (nodes connected via in- or outgoing edges)
     */
    public var neighbours: Set<Node> { ancestors + descendants }
    
    /**
     The node's ancestors (nodes connected via ingoing edges)
     */
    public internal(set) var ancestors = Set<Node>()
    
    /**
     The node's descendants (nodes connected via outgoing edges)
     */
    public internal(set) var descendants = Set<Node>()
    
    // MARK: - Hashability
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    public static func == (lhs: Node, rhs: Node) -> Bool { lhs === rhs }
    
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
