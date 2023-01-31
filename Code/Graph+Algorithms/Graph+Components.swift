import SwiftyToolz

public extension Graph
{
    /**
     Find the [components](https://en.wikipedia.org/wiki/Component_(graph_theory)) of the `Graph`
     
     - Returns: Multiple sets of nodes which represent the components of the graph
     */
    func findComponents() -> Set<NodeIDs>
    {
        var markedNodes = NodeIDs()
        
        var components = Set<NodeIDs>()

        for node in nodeIDs
        {
            if markedNodes.contains(node) { continue }
            
            components += findLackingNodes(forComponent: [], startingAt: node)
            
            markedNodes.insert(node)
        }

        return components
    }
    
    private func findLackingNodes(forComponent incompleteComponent: NodeIDs,
                                  startingAt startNode: NodeID) -> NodeIDs
    {
        guard !incompleteComponent.contains(startNode) else { return [] }
        
        var lackingNodes: NodeIDs = [startNode]
        
        let neighbours = node(for: startNode)?.neighbourIDs ?? []
        
        for neighbour in neighbours
        {
            let extendedComponent = incompleteComponent + lackingNodes
            lackingNodes += findLackingNodes(forComponent: extendedComponent,
                                             startingAt: neighbour)
        }
        
        return lackingNodes
    }
}
