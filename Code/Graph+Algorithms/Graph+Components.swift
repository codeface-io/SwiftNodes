import SwiftyToolz

public extension Graph
{
    func findComponents() -> Set<Nodes>
    {
        unmarkNodes()
        
        var components = Set<Nodes>()

        for node in nodesByValueID.values
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
