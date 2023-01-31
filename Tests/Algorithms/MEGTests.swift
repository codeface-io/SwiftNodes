@testable import SwiftNodes
import XCTest

class MEGTests: XCTestCase {

    func testGraphWithOneTransitiveEdge() {
        let graph = Graph(values: [1, 2, 3],
                          edges: [(1, 2), (2, 3), (1, 3)])
        
        XCTAssertEqual(graph.edges.count, 3)
        
        let meg = graph.makeMinimumEquivalentGraph()
        
        XCTAssertEqual(meg.edges.count, 2)
        XCTAssertNotNil(meg.edge(from: 1, to: 2))
        XCTAssertNotNil(meg.edge(from: 2, to: 3))
        XCTAssertNil(meg.edge(from: 1, to: 3))
    }
}
