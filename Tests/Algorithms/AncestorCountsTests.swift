@testable import SwiftNodes
import XCTest

class AncestorCountsTests: XCTestCase {
    
    func testEmptyGraph() {
        XCTAssertEqual(Graph<Int, Int>().findNumberOfNodeAncestors(),
                       [:])
    }
    
    func testGraphWithoutEdges() {
        let graph = Graph(values: [1, 2, 3])
        
        XCTAssertEqual(graph.findNumberOfNodeAncestors(),
                       [1: 0, 2: 0, 3: 0])
    }
    
    func testGraphWithoutTransitiveEdges() {
        let graph = Graph(values: [1, 2, 3],
                          edges: [(1, 2), (2, 3)])
        
        XCTAssertEqual(graph.findNumberOfNodeAncestors(),
                       [1: 0, 2: 1, 3: 2])
    }
    
    func testGraphWithOneTransitiveEdge() {
        let graph = Graph(values: [1, 2, 3],
                          edges: [(1, 2), (2, 3), (1, 3)])
        
        XCTAssertEqual(graph.findNumberOfNodeAncestors(),
                       [1: 0, 2: 1, 3: 2])
    }
    
    func testGraphWithTwoComponentsEachWithOneTransitiveEdge() {
        let graph = Graph(values: [1, 2, 3, 4, 5, 6],
                          edges: [(1, 2), (2, 3), (1, 3), (4, 5), (5, 6), (4, 6)])
        
        XCTAssertEqual(graph.findNumberOfNodeAncestors(),
                       [1: 0, 2: 1, 3: 2, 4: 0, 5: 1, 6: 2])
    }
    
    func testGraphWithTwoSourcesAnd4PathsToSink() {
        let graph = Graph(values: [0, 1, 2, 3, 4, 5],
                          edges: [(0, 2), (1, 2), (2, 3), (2, 4), (3, 5), (4, 5)])
        
        XCTAssertEqual(graph.findNumberOfNodeAncestors(),
                       [0: 0, 1: 0, 2: 2, 3: 3, 4: 3, 5: 5])
    }
}
