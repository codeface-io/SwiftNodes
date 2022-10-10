import SwiftyToolz

public extension Graph
{
    /**
     Find the [components](https://en.wikipedia.org/wiki/Component_(graph_theory)) of the `Graph`
     
     - Returns: Multiple sets of nodes which represent the components of the graph
     */
    func findComponents() -> Set<Nodes>
    {
        unmarkNodes()
        
        var components = Set<Nodes>()

        for node in nodesByID.values
        {
            if node.isMarked { continue }
            
            let nextComponent = findLackingNodes(forComponent: [], startingAt: node)
            
            components += nextComponent
            
            node.mark()
        }

        return components
    }
    
    private func findLackingNodes(forComponent incompleteComponent: Nodes,
                                  startingAt node: Node) -> Nodes
    {
        guard !incompleteComponent.contains(node) else { return [] }
        
        var lackingNodes: Nodes = [node]
        
        for neighbour in node.neighbours
        {
            let extendedComponent = incompleteComponent + lackingNodes
            lackingNodes += findLackingNodes(forComponent: extendedComponent, startingAt: neighbour)
        }
        
        return lackingNodes
    }
}
