import SwiftyToolz

public extension Graph
{
    func findComponents() -> Set<Nodes>
    {
        var nodesToSearch = Set(nodes)
        var components = Set<Nodes>()

        while let nodeToSearch = nodesToSearch.first
        {
            let nextComponent = findLackingNodes(forComponent: [],
                                                 startingAt: nodeToSearch)
            components += nextComponent
            nodesToSearch -= nextComponent
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
            lackingNodes += findLackingNodes(forComponent: extendedComponent,
                                             startingAt: neighbour)
        }
        
        return lackingNodes
    }
}
