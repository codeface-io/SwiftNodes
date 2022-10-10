import SwiftyToolz

extension Graph
{
    /**
     Find the [strongly connected components](https://en.wikipedia.org/wiki/Strongly_connected_component) of the `Graph`
     
     - Returns: Multiple sets of nodes which represent the strongly connected components of the graph
     */
    func findStronglyConnectedComponents() -> Set<Nodes>
    {
        unmarkNodes()
        
        var resultingSCCs = Set<Nodes>()
        
        var index = 0
        var stack = [Node]()
        
        for node in nodes
        {
            if !node.isMarked
            {
                findSCCsRecursively(node: node,
                                    index: &index,
                                    stack: &stack) { resultingSCCs += $0 }
            }
        }
        
        return resultingSCCs
    }
    
    @discardableResult
    private func findSCCsRecursively(node: Node,
                                     index: inout Int,
                                     stack: inout [Node],
                                     handleNewSCC: (Nodes) -> Void) -> Node.Marking
    {
        // Set the depth index for node to the smallest unused index
        assert(!node.isMarked, "there shouldn't be a marking value on this node yet")
        let nodeMarking = Node.Marking(index: index, lowLink: index, isOnStack: true)
        node.mark(with: nodeMarking)
        index += 1
        stack.append(node)
        
        // Consider descendants of node
        for descendant in node.descendants
        {
            if let descendantMarking = descendant.marking
            {
                // If descendant is not on stack, then edge (node, descendant) is pointing to an SCC already found and must be ignored
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
                                                            handleNewSCC: handleNewSCC)
                
                nodeMarking.lowLink = min(nodeMarking.lowLink, descendantMarking.lowLink)
            }
        }
        
        // If node is a root node, pop the stack and generate an SCC
        if nodeMarking.lowLink == nodeMarking.index
        {
            var newSCC = Nodes()
            
            while !stack.isEmpty
            {
                let sccNode = stack.removeLast()
                
                guard let sccNodeMarkings = sccNode.marking else
                {
                    fatalError("node that is on the stack should have a markings object")
                }
                
                sccNodeMarkings.isOnStack = false
                newSCC += sccNode
                
                if node === sccNode { break }
            }
            
            handleNewSCC(newSCC)
        }
        
        return nodeMarking
    }
}

private extension GraphNode.Marking
{
    convenience init(index: Int, lowLink: Int, isOnStack: Bool)
    {
        self.init(number1: index, number2: lowLink, flag1: isOnStack)
    }
    
    var index: Int
    {
        get { number1 }
        set { number1 = newValue }
    }
    
    var lowLink: Int
    {
        get { number2 }
        set { number2 = newValue }
    }
    
    var isOnStack: Bool
    {
        get { flag1 }
        set { flag1 = newValue }
    }
}
