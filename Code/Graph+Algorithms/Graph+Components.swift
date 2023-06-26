import SwiftyToolz

public extension Graph
{
    /**
     Find the [components](https://en.wikipedia.org/wiki/Component_(graph_theory)) of the `Graph`
     
     - Returns: Multiple sets of nodes which represent the components of the graph
     */
    func findComponents() -> Set<NodeIDs>
    {
        var visitedNodes = NodeIDs()
        
        var components = Set<NodeIDs>()

        for node in nodeIDs
        {
            if visitedNodes.contains(node) { continue }
            
            // this node has not been visited yet
            
            components += Set(findLackingNodes(forComponent: [],
                                               startingAt: node,
                                               visitedNodes: &visitedNodes))
            
            visitedNodes.insert(node)
        }

        return components
    }
    
    /// startNode is connected to the incompleteComponent but not contained in it. both will be in the resulting actual component.
    private func findLackingNodes(forComponent incompleteComponent: [NodeID],
                                  startingAt startNode: NodeID,
                                  visitedNodes: inout NodeIDs) -> [NodeID]
    {
        var lackingNodes = [startNode]
        
        visitedNodes += startNode
        
        let neighbours = node(with: startNode)?.neighbourIDs ?? []
        
        for neighbour in neighbours
        {
            if visitedNodes.contains(neighbour) { continue }
            
            let extendedComponent = incompleteComponent + lackingNodes
            lackingNodes += findLackingNodes(forComponent: extendedComponent,
                                             startingAt: neighbour,
                                             visitedNodes: &visitedNodes)
        }
        
        return lackingNodes
    }
}
