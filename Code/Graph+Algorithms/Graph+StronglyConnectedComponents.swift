import SwiftyToolz

extension Graph
{
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
        for target in node.descendants
        {
            if let targetMarkings = target.marking
            {
                // If target is not on stack, then edge (node, target) is pointing to an SCC already found and must be ignored
                if targetMarkings.isOnStack
                {
                    // Successor "target" is in stack and hence in the current SCC
                    nodeMarking.lowLink = min(nodeMarking.lowLink, targetMarkings.index)
                }
            }
            else // if target index is undefined then
            {
                // Successor "target" has not yet been visited; recurse on it
                let targetMarking = findSCCsRecursively(node: target,
                                                        index: &index,
                                                        stack: &stack,
                                                        handleNewSCC: handleNewSCC)
                
                nodeMarking.lowLink = min(nodeMarking.lowLink, targetMarking.lowLink)
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
