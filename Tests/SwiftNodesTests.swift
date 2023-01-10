@testable import SwiftNodes
import XCTest

class SwiftNodesTests: XCTestCase {
    
    func testCodeExamplesFromREADME() throws {
        var graph = Graph<String, Int> { "id\($0)" }  // NodeID == String, NodeValue == Int
        let node1 = graph.insert(1)                   // node1.id == "id1"
        
        let valueForID1 = graph.value(for: "id1")     // valueForID1 == 1
        let nodeForID1 = graph.node(for: "id1")       // nodeForID1 === node1
        
        XCTAssertEqual(valueForID1, node1.value)
        XCTAssertEqual(nodeForID1?.id, node1.id)
    }
    
    func testAddingEdges() throws {
        var graph = Graph<String, Int> { "id\($0)" }
        let node1 = graph.insert(1)
        let node2 = graph.insert(2)
        graph.addEdge(from: node1.id, to: node2.id)
        
        XCTAssertNotNil(graph.edge(from: node1.id, to: node2.id))
        XCTAssertNil(graph.edge(from: node2.id, to: node1.id))
        XCTAssertEqual(graph.edge(from: node1.id, to: node2.id)?.count, 1)
    }
    
    func testAddingEdgeWithBigCount() throws {
        var graph = Graph<String, Int> { "id\($0)" }
        let node1 = graph.insert(1)
        let node2 = graph.insert(2)
        
        graph.addEdge(from: node1.id, to: node2.id, count: 42)
        XCTAssertEqual(graph.edge(from: node1.id, to: node2.id)?.count, 42)
        
        graph.addEdge(from: node1.id, to: node2.id, count: 58)
        XCTAssertEqual(graph.edge(from: node1.id, to: node2.id)?.count, 100)
    }
    
    func testEdgesAreDirected() throws {
        var graph = Graph<String, Int> { "id\($0)" }
        let node1 = graph.insert(1)
        let node2 = graph.insert(2)
        XCTAssertNotNil(graph.addEdge(from: node1.id, to: node2.id))
        XCTAssertNil(graph.edge(from: node2.id, to: node1.id))
    }
    
    func testUUIDAsID() throws {
        var graph = Graph<UUID, Int> { _ in UUID() }  // NodeID == UUID, NodeValue == Int
        let node1 = graph.insert(1)
        let node2 = graph.insert(1)
        XCTAssertNotEqual(node1.id, node2.id)
        XCTAssertEqual(node1.value, node2.value)
        XCTAssertNotEqual(node1.id, node2.id)
    }
    
    func testOmittingClosureForIdentifiableValues() throws {
        struct IdentifiableValue: Identifiable { let id = UUID() }
        var graph = Graph<UUID, IdentifiableValue>()  // NodeID == NodeValue.ID == UUID
        let node = graph.insert(IdentifiableValue())  // node.id == node.value.id
        XCTAssertEqual(node.id, node.value.id)
    }
    
    func testSorting() throws {
        var graph = Graph<Int, Int>()
        
        let node1 = graph.insert(1)
        let node2 = graph.insert(2)
        let edge = graph.addEdge(from: node1.id, to: node2.id)
        
        graph.removeEdge(with: edge.id)
        graph.removeEdge(with: .init(node1.id, node2.id))
        graph.removeEdge(from: node1.id, to: node2.id)
    }
    
    func testSixWaysToRemoveAnEdgeDoCompile() {
        var graph = Graph<Int, Int>()
        let node1 = graph.insert(5)
        let node2 = graph.insert(3)
        let edge = graph.addEdge(from: node1.id, to: node2.id)
        
        XCTAssertNotNil(edge)
        XCTAssertEqual(edge.id, graph.edge(from: node1.id, to: node2.id)?.id)
        
        graph.removeEdge(with: edge.id)
        
        XCTAssertNil(graph.edge(from: node1.id, to: node2.id))
        
        graph.removeEdge(with: .init(node1.id, node2.id))
        graph.removeEdge(from: node1.id, to: node2.id)
    }
    
    func testInsertingConnectingAndDisconnectingValues() throws {
        var graph = Graph<String, Int> { "id\($0)" }
        XCTAssertNil(graph.node(for: "id1"))
        XCTAssertNil(graph.value(for: "id1"))
        
        let node1 = graph.insert(1)
        XCTAssertEqual(graph.value(for: "id1"), 1)
        XCTAssertEqual(graph.node(for: "id1")?.id, node1.id)
        XCTAssertEqual(graph.insert(1).id, node1.id)
        XCTAssertNil(graph.edge(from: "id1", to: "id2"))
        
        XCTAssertEqual(node1.id, "id1")
        XCTAssertEqual(node1.value, 1)

        let node2 = graph.insert(2)
        XCTAssertNil(graph.edge(from: "id1", to: "id2"))
        XCTAssertNil(graph.edge(from: node1.id, to: node2.id))
        
        let edge12 = graph.addEdge(from: node1.id, to: node2.id)
        XCTAssertNotNil(graph.edge(from: "id1", to: "id2"))
        XCTAssertNotNil(graph.edge(from: node1.id, to: node2.id))
        
        XCTAssertEqual(edge12.count, 1)
        XCTAssertEqual(edge12.id, graph.addEdge(from: "id1", to: "id2").id)
        XCTAssertEqual(graph.edge(from: node1.id, to: node2.id)?.count, 2)
        XCTAssertEqual(edge12.originID, node1.id)
        XCTAssertEqual(edge12.destinationID, node2.id)
        
        guard let updatedNode1 = graph.node(for: node1.id) else
        {
            throw "There should still exist a node for the id of node 1"
        }
        
        XCTAssertFalse(updatedNode1.isSink)
        XCTAssert(updatedNode1.descendantIDs.contains(node2.id))
        XCTAssert(updatedNode1.isSource)
        
        guard let updatedNode2 = graph.node(for: node2.id) else
        {
            throw "There should still exist a node for the id of node 2"
        }
        
        XCTAssertFalse(updatedNode2.isSource)
        XCTAssert(updatedNode2.ancestorIDs.contains(node1.id))
        XCTAssert(updatedNode2.isSink)
        
        graph.removeEdge(with: edge12.id)
        XCTAssertNil(graph.edge(from: "id1", to: "id2"))
        XCTAssertNil(graph.edge(from: node1.id, to: node2.id))
        
        guard let finalNode1 = graph.node(for: node1.id),
              let finalNode2 = graph.node(for: node2.id) else
        {
            throw "There should still exist node for the ids of nodes 1 and 2"
        }
        
        XCTAssert(finalNode1.ancestorIDs.isEmpty)
        XCTAssert(finalNode1.descendantIDs.isEmpty)
        XCTAssert(finalNode1.isSource)
        XCTAssert(finalNode1.isSink)
        XCTAssert(finalNode2.ancestorIDs.isEmpty)
        XCTAssert(finalNode2.descendantIDs.isEmpty)
        XCTAssert(finalNode2.isSource)
        XCTAssert(finalNode2.isSink)
    }
    
    func testMinimumEquivalentGraph() {
        // make original graph
        var graph = Graph<String, Int> { "id\($0)" }
        
        let node1 = graph.insert(1)
        let node2 = graph.insert(2)
        let node3 = graph.insert(3)
        
        graph.addEdge(from: node1.id, to: node2.id)
        graph.addEdge(from: node2.id, to: node3.id)
        graph.addEdge(from: node1.id, to: node3.id)
        
        XCTAssertEqual(graph.edges.count, 3)
        
        // make MEG
        let meg = graph.makeMinimumEquivalentGraph()
        
        XCTAssertEqual(meg.edges.count, 2)
        XCTAssertNotNil(meg.edge(from: "id1", to: "id2"))
        XCTAssertNotNil(meg.edge(from: "id2", to: "id3"))
        XCTAssertNil(meg.edge(from: "id1", to: "id3"))
    }
    
    func testSubGraph() {
        var graph = Graph<Int, Int>()
        
        for value in 0 ... 20
        {
            graph.insert(value)
        }
        
        for value in 0 ... 19
        {
            graph.addEdge(from: value, to: value + 1)
        }
        
        XCTAssertEqual(graph.edges.count, 20)
        XCTAssertNotNil(graph.edge(from: 12, to: 13))
        
        let subsetOfNodeIDs: Set<Int> = [0, 3, 6, 9, 12, 13, 14, 15]
        let subGraph = graph.subGraph(nodeIDs: subsetOfNodeIDs)
        
        XCTAssertEqual(graph.edges.count, 20)
        XCTAssertNotNil(graph.edge(from: 9, to: 10))
        
        XCTAssertEqual(subGraph.edges.count, 3)
        XCTAssertNil(subGraph.edge(from: 9, to: 10))
    }
    
    // TODO: Test more algorithms
}
