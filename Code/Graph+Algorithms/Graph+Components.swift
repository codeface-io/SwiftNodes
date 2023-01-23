import SwiftyToolz

public extension Graph
{
    // TODO: this can be accelerated a bit by only working with- and returning Node IDs instead of Nodes. Only for where we actually need the neighbour IDs do we need to hash the Node itself. The client can then decide whether it actually needs the nodes or whether the IDs suffice ...
    
    /**
     Find the [components](https://en.wikipedia.org/wiki/Component_(graph_theory)) of the `Graph`
     
     - Returns: Multiple sets of nodes which represent the components of the graph
     */
    func findComponents() -> Set<NodeIDs>
    {
        var markedNodes = NodeIDs()
        
        var components = Set<NodeIDs>()

        for node in nodesIDs
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
