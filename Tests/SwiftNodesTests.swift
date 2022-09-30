@testable import SwiftNodes
import XCTest

class SwiftNodesTests: XCTestCase {
    
    func testInsertingAndConnectingValues() throws {
        let graph = Graph<Int, Int>()
        
        let node1 = graph.insert(1)
        XCTAssertIdentical(node1, graph.insert(1))
        XCTAssertEqual(node1.id, 1)
        XCTAssertEqual(node1.value, 1)
        XCTAssert(node1.ancestors.isEmpty)
        XCTAssert(node1.descendants.isEmpty)
        XCTAssert(node1.isSource)
        XCTAssert(node1.isSink)
        XCTAssertNil(graph.edge(from: 1, to: 2))

        let node2 = graph.insert(2)
        XCTAssertNil(graph.edge(from: 1, to: 2))
        XCTAssertNil(graph.edge(from: node1, to: node2))
        
        let edge12 = graph.addEdge(from: node1, to: node2)
        XCTAssertEqual(edge12.count, 1)
        let edge12viaIDsAgain = graph.addEdge(from: 1, to: 2)
        XCTAssertIdentical(edge12, edge12viaIDsAgain)
        XCTAssertEqual(edge12.count, 2)
        XCTAssertIdentical(edge12.source, node1)
        XCTAssertIdentical(edge12.target, node2)
        XCTAssertNotNil(graph.edge(from: 1, to: 2))
        XCTAssertNotNil(graph.edge(from: node1, to: node2))
        XCTAssert(node1.isSource)
        XCTAssertFalse(node1.isSink)
        XCTAssertFalse(node2.isSource)
        XCTAssert(node2.isSink)
    }
}
