@testable import SwiftNodes
import XCTest

class EdgeTests: XCTestCase {
    
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
    
    func testMultipleWaysToRemoveAnEdgeDoCompile() {
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
}