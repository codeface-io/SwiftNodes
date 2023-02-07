public extension Graph
{
    subscript(_ nodeID: NodeID) -> NodeValue?
    {
        get
        {
            nodesByID[nodeID]?.value
        }
        
        set
        {
            guard let newValue else
            {
                removeNode(with: nodeID)
                return
            }
            
            update(newValue, for: nodeID)
        }
    }
    
    @discardableResult
    mutating func insert(_ value: NodeValue) -> Node where NodeValue: Identifiable, NodeValue.ID == NodeID
    {
        update(value, for: value.id)
    }
    
    @discardableResult
    mutating func insert(_ value: NodeValue) -> Node where NodeID == NodeValue
    {
        update(value, for: value)
    }
    
    /**
     Insert a `NodeValue` and get the (new) ``GraphNode`` that stores it
     
     - Returns: The (possibly new) ``GraphNode`` holding the value
     */
    @discardableResult
    mutating func update(_ value: NodeValue, for nodeID: NodeID) -> Node
    {
        if var node = nodesByID[nodeID]
        {
            node.value = value
            nodesByID[nodeID] = node
            return node
        }
        else
        {
            let node = Node(id: nodeID, value: value)
            nodesByID[nodeID] = node
            return node
        }
    }
    
    /**
     ``GraphNode/value`` of the ``GraphNode`` with the given ``GraphNode/id`` if one exists, otherwise `nil`
     */
    func value(for nodeID: NodeID) -> NodeValue?
    {
        nodesByID[nodeID]?.value
    }
    
    /**
     All `NodeValue`s of the `Graph`
     */
    var values: some Collection<NodeValue>
    {
        nodesByID.values.map { $0.value }
    }
}
