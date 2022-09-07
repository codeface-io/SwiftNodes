import OrderedCollections

public extension Graph
{
    // MARK: - Edges
    
    mutating func addEdge(from sourceValue: NodeValue, to targetValue: NodeValue)
    {
        addEdge(from: sourceValue.id, to: targetValue.id)
    }
    
    mutating func addEdge(from sourceValueID: NodeValue.ID, to targetValueID: NodeValue.ID)
    {
        guard let sourceNode = node(for: sourceValueID),
              let targetNode = node(for: targetValueID) else { return }
        
        addEdge(from: sourceNode, to: targetNode)
    }
    
    func edge(from sourceValue: NodeValue, to targetValue: NodeValue) -> Edge?
    {
        edge(from: sourceValue.id, to: targetValue.id)
    }
    
    func edge(from sourceValueID: NodeValue.ID, to targetValueID: NodeValue.ID) -> Edge?
    {
        edgesByID[.init(sourceValueID: sourceValueID, targetValueID: targetValueID)]
    }
    
    // MARK: - Nodes
    
    func node(for value: NodeValue) -> Node?
    {
        node(for: value.id)
    }
    
    func node(for valueID: NodeValue.ID) -> Node?
    {
        nodesByValueID[valueID]
    }
    
    // MARK: - Values
    
    init(values: OrderedSet<NodeValue>)
    {
        self.nodesByValueID = .init(uniqueKeysWithValues: values.map { ($0.id, Node(value: $0)) })
    }
    
    mutating func sort(by valuesAreInOrder: (NodeValue, NodeValue) -> Bool)
    {
        nodesByValueID.sort { valuesAreInOrder($0.value.value, $1.value.value) }
    }
    
    @discardableResult
    mutating func insert(_ value: NodeValue) -> Node
    {
        if let node = nodesByValueID[value.id]
        {
            node.value = value
            return node
        }
        else
        {
            let node = Node(value: value)
            nodesByValueID[value.id] = node
            return node
        }
    }
    
    var values: OrderedSet<NodeValue> { OrderedSet(nodesByValueID.mapValues({ $0.value }).values) }
}
