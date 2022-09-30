@testable import SwiftNodes
import XCTest

class SwiftNodesTests: XCTestCase {
    
    func testInsertingConnectingAndDisconnectingValues() throws {
        let graph = Graph<String, Int> { "id\($0)" }
        XCTAssertNil(graph.node(for: "id1"))
        XCTAssertNil(graph.value(for: "id1"))
        
        let node1 = graph.insert(1)
        XCTAssertEqual(graph.value(for: "id1"), 1)
        XCTAssertIdentical(graph.node(for: "id1"), node1)
        XCTAssertIdentical(graph.insert(1), node1)
        XCTAssertNil(graph.edge(from: "id1", to: "id2"))
        
        XCTAssertEqual(node1.id, "id1")
        XCTAssertEqual(node1.value, 1)
        
        XCTAssert(node1.ancestors.isEmpty)
        XCTAssert(node1.descendants.isEmpty)
        XCTAssert(node1.isSource)
        XCTAssert(node1.isSink)

        let node2 = graph.insert(2)
        XCTAssertNil(graph.edge(from: "id1", to: "id2"))
        XCTAssertNil(graph.edge(from: node1, to: node2))
        
        let edge12 = try graph.addEdge(from: node1.id, to: node2.id).unwrap()
        XCTAssertNotNil(graph.edge(from: "id1", to: "id2"))
        XCTAssertNotNil(graph.edge(from: node1, to: node2))
        
        XCTAssertEqual(edge12.count, 1)
        XCTAssertIdentical(edge12, graph.addEdge(from: "id1", to: "id2"))
        XCTAssertEqual(edge12.count, 2)
        XCTAssertIdentical(edge12.source, node1)
        XCTAssertIdentical(edge12.target, node2)
        
        XCTAssertFalse(node1.isSink)
        XCTAssert(node1.descendants.contains(node2))
        XCTAssert(node1.isSource)
        
        XCTAssertFalse(node2.isSource)
        XCTAssert(node2.ancestors.contains(node1))
        XCTAssert(node2.isSink)
        
        graph.removeEdge(with: edge12.id)
        XCTAssertNil(graph.edge(from: "id1", to: "id2"))
        XCTAssertNil(graph.edge(from: node1, to: node2))
        
        XCTAssertEqual(edge12.count, 0)
        
        XCTAssert(node1.ancestors.isEmpty)
        XCTAssert(node1.descendants.isEmpty)
        XCTAssert(node1.isSource)
        XCTAssert(node1.isSink)
        XCTAssert(node2.ancestors.isEmpty)
        XCTAssert(node2.descendants.isEmpty)
        XCTAssert(node2.isSource)
        XCTAssert(node2.isSink)
    }
    
    func testGraphCopying() {
        let graph = Graph<String, Int> { "id\($0)" }
        
        let node1 = graph.insert(1)
        let node2 = graph.insert(2)
        let node3 = graph.insert(3)
        
        let edge1 = graph.addEdge(from: node1, to: node2)
        _ = graph.addEdge(from: node2, to: node3, count: 2)
        
        let graphCopy = graph.copy()
        XCTAssertEqual(graph.values, graphCopy.values)
        XCTAssertEqual(graph.nodesIDs, graphCopy.nodesIDs)
        XCTAssert(Set(graph.nodes).intersection(Set(graphCopy.nodes)).isEmpty)
        XCTAssertEqual(graph.value(for: "id3"), graphCopy.value(for: "id3"))
        
        XCTAssertNil(graphCopy.edge(from: node1, to: node2))
        XCTAssertNotNil(graphCopy.edge(from: "id1", to: "id2"))
        XCTAssertNotNil(graphCopy.edge(from: "id2", to: "id3"))
        XCTAssertNil(graphCopy.edge(from: "id1", to: "id3"))
        XCTAssertNotIdentical(graphCopy.edge(from: "id1", to: "id2"), edge1)
        XCTAssertEqual(graphCopy.edge(from: "id2", to: "id3")?.count, 2)
    }
    
    // TODO: Test algorithms
}
