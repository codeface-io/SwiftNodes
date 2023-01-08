import SwiftyToolz

public extension Graph
{
    // TODO: this can be accelerated a bit by only working with- and returning Node IDs instead of Nodes. Only for where we actually need the neighbour IDs do we need to hash the Node itself. The client can then decide whether it actually needs the nodes or whether the IDs suffice ...
    
    /**
     Find the [components](https://en.wikipedia.org/wiki/Component_(graph_theory)) of the `Graph`
     
     - Returns: Multiple sets of nodes which represent the components of the graph
     */
    func findComponents() -> Set<Nodes>
    {
        var markedNodes = Nodes()
        
        var components = Set<Nodes>()

        for node in nodes
        {
            if markedNodes.contains(node) { continue }
            
            components += findLackingNodes(forComponent: [], startingAt: node)
            
            markedNodes.insert(node)
        }

        return components
    }
    
    private func findLackingNodes(forComponent incompleteComponent: Nodes,
                                  startingAt node: Node) -> Nodes
    {
        guard !incompleteComponent.contains(node) else { return [] }
        
        var lackingNodes: Nodes = [node]
        
        for neighbourID in node.neighbourIDs
        {
            guard let neighbour = self.node(for: neighbourID) else { continue }
            let extendedComponent = incompleteComponent + lackingNodes
            lackingNodes += findLackingNodes(forComponent: extendedComponent,
                                             startingAt: neighbour)
        }
        
        return lackingNodes
    }
}
