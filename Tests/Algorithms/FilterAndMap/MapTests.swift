@testable import SwiftNodes
import XCTest

class MapTests: XCTestCase {
        
    func testMappingIntValuesToString() {
        let graph: TestGraph = [1, 2, 3]
        let stringGraph = graph.map { "\($0)" }
        let expectedStringGraph: Graph<Int, String, Int> = [1: "1", 2: "2", 3: "3"]
        XCTAssertEqual(stringGraph, expectedStringGraph)
    }
}
