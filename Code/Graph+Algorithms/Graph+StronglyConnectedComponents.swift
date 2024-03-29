import SwiftyToolz

extension Graph
{
    /**
     Find the [strongly connected components](https://en.wikipedia.org/wiki/Strongly_connected_component) of the `Graph`
     
     - Returns: Multiple sets of node IDs, each set representing a strongly connected components of the graph
     */
    func findStronglyConnectedComponents() -> Set<NodeIDs>
    {
        var resultingSCCs = Set<NodeIDs>()
        
        var index = 0
        var stack = [NodeID]()
        var markings = [NodeID: Marking]()
        
        for node in nodeIDs
        {
            if markings[node] == nil
            {
                findSCCsRecursively(node: node,
                                    index: &index,
                                    stack: &stack,
                                    markings: &markings) { resultingSCCs += $0 }
            }
        }
        
        return resultingSCCs
    }
    
    @discardableResult
    private func findSCCsRecursively(node: NodeID,
                                     index: inout Int,
                                     stack: inout [NodeID],
                                     markings: inout [NodeID: Marking],
                                     handleNewSCC: (NodeIDs) -> Void) -> Marking
    {
        // Set the depth index for node to the smallest unused index
        assert(markings[node] == nil, "there shouldn't be a marking value for this node yet")
        let nodeMarking = Marking(index: index, lowLink: index, isOnStack: true)
        markings[node] = nodeMarking
        index += 1
        stack.append(node)
        
        // Consider descendants of node
        let nodeDescendants = self.node(with: node)?.descendantIDs ?? []
        
        for descendant in nodeDescendants
        {
            if let descendantMarking = markings[descendant]
            {
                // If descendant is not on stack, then edge (from node to descendant) is pointing to an SCC already found and must be ignored
                if descendantMarking.isOnStack
                {
                    // Successor "descendant" is in stack and hence in the current SCC
                    nodeMarking.lowLink = min(nodeMarking.lowLink, descendantMarking.index)
                }
            }
            else // if descendant index is undefined then
            {
                // Successor "descendant" has not yet been visited; recurse on it
                let descendantMarking = findSCCsRecursively(node: descendant,
                                                            index: &index,
                                                            stack: &stack,
                                                            markings: &markings,
                                                            handleNewSCC: handleNewSCC)
                
                nodeMarking.lowLink = min(nodeMarking.lowLink, descendantMarking.lowLink)
            }
        }
        
        // If node is a root node, pop the stack and generate an SCC
        if nodeMarking.lowLink == nodeMarking.index
        {
            var newSCC = NodeIDs()
            
            while !stack.isEmpty
            {
                let sccNode = stack.removeLast()
                
                guard markings[sccNode] != nil else
                {
                    fatalError("node that is on the stack should have a markings object")
                }
                
                markings[sccNode]?.isOnStack = false
                newSCC += sccNode
                
                if node == sccNode { break }
            }
            
            handleNewSCC(newSCC)
        }
        
        return nodeMarking
    }
}

private class Marking
{
    init(index: Int, lowLink: Int, isOnStack: Bool)
    {
        self.index = index
        self.lowLink = lowLink
        self.isOnStack = isOnStack
    }
    
    var index: Int
    var lowLink: Int
    var isOnStack: Bool
}
