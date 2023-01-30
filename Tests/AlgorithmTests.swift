@testable import SwiftNodes
import XCTest

class AlgorithmTests: XCTestCase {
    
    func testMinimumEquivalentGraph() {
        // make original graph
        let graph = Graph(values: [1, 2, 3],
                          edges: [(1, 2), (2, 3), (1, 3)])
        
        XCTAssertEqual(graph.edges.count, 3)
        
        // make MEG
        let meg = graph.makeMinimumEquivalentGraph()
        
        XCTAssertEqual(meg.edges.count, 2)
        XCTAssertNotNil(meg.edge(from: 1, to: 2))
        XCTAssertNotNil(meg.edge(from: 2, to: 3))
        XCTAssertNil(meg.edge(from: 1, to: 3))
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
}
