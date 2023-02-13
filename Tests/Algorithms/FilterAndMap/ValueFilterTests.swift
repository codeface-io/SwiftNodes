@testable import SwiftNodes
import XCTest

class ValueFilterTests: XCTestCase {
    
    func testValueFilter() {
        let graph: Graph<Int, Int, Int> = [1, 2, 10, 20]
        let filteredGraph = graph.filtered { $0 < 10 }
        let expectedFilteredGraph: Graph<Int, Int, Int> = [1, 2]
        XCTAssertEqual(filteredGraph, expectedFilteredGraph)
    }
}
