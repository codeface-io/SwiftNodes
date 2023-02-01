@testable import SwiftNodes
import XCTest

class MEGTests: XCTestCase {

    func testGraphWithOneTransitiveEdge() {
        let graph = Graph(values: [1, 2, 3],
                          edges: [(1, 2), (2, 3), (1, 3)])
        
        let expectedMEG = Graph(values: [1, 2, 3],
                                edges: [(1, 2), (2, 3)])
        
        XCTAssertEqual(graph.makeMinimumEquivalentGraph(), expectedMEG)
    }
}
