import SwiftyToolz

public extension Graph
{
    func subGraph(nodeIDs: NodeIDs) -> Graph<NodeID, NodeValue>
    {
        var subGraph = self
        
        let idsOfNodesToRemove = Set(nodesByID.keys) - nodeIDs
        
        for idOfNodeToRemove in idsOfNodesToRemove
        {
            subGraph.removeNode(with: idOfNodeToRemove)
        }
        
        return subGraph
    }
}
