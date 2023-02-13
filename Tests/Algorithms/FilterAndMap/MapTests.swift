@testable import SwiftNodes
import XCTest

class MapTests: XCTestCase {
        
    func testMappingIntValuesToString() {
        let intGraph: Graph<Int, Int, Int> = [1, 2, 3]
        let stringGraph = intGraph.map { "\($0)" }
        let expectedStringGraph: Graph<Int, String, Int> = [1: "1", 2: "2", 3: "3"]
        XCTAssertEqual(stringGraph, expectedStringGraph)
    }
}
