@testable import SwiftNodes
import XCTest

class SubgraphTests: XCTestCase {
    
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
}
