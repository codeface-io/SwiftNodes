@testable import SwiftNodes
import XCTest

class NonEssentialEdgesTests: XCTestCase {
    
    func testEmptyGraph() {
        XCTAssert(Graph<Int, Int>().findNonEssentialEdges().isEmpty)
    }
    
    func testGraphWithoutEdges() {
        let graph = Graph(values: [1, 2, 3])
        
        XCTAssert(graph.findNonEssentialEdges().isEmpty)
    }
    
    func testGraphWithoutTransitiveEdges() {
        let graph = Graph(values: [1, 2, 3],
                          edges: [(1, 2), (2, 3)])
        
        XCTAssert(graph.findNonEssentialEdges().isEmpty)
    }
    
    func testGraphWithOneTransitiveEdge() {
        let graph = Graph(values: [1, 2, 3],
                          edges: [(1, 2), (2, 3), (1, 3)])
        
        XCTAssertEqual(graph.findNonEssentialEdges(), [.init(1, 3)])
    }
    
    func testAcyclicGraphWithManyTransitiveEdges() {
        var graph = Graph<Int, Int>()
        
        let numberOfNodes = 10
        
        for j in 0 ..< numberOfNodes
        {
            graph.insert(j)
            
            for i in 0 ..< j
            {
                graph.addEdge(from: i, to: j)
            }
        }
        
        // sanity check
        let expectedNumberOfEdges = ((numberOfNodes * numberOfNodes) - numberOfNodes) / 2
        XCTAssertEqual(graph.edges.count, expectedNumberOfEdges)
        
        // only edges between neighbouring numbers are essential (0 -> 1 -> 2 ...)
        
        var expectedNonEssentialEdges = Set<GraphEdge<Int>.ID>()
        
        for j in 2 ..< numberOfNodes
        {
            for i in 0 ... j - 2
            {
                expectedNonEssentialEdges.insert(.init(i, j))
            }
        }
        
        XCTAssertEqual(graph.findNonEssentialEdges(), expectedNonEssentialEdges)
    }
    
    func testGraphWithTwoCyclesButOnlyEssentialEdges() {
        let graph = Graph(values: [1, 2, 3, 4, 5, 6],
                          edges: [(1, 2), (2, 3), (3, 1), (3, 4), (4, 5), (5, 6), (6, 4)])
        
        XCTAssert(graph.findNonEssentialEdges().isEmpty)
    }
    
    func testGraphWithTwoCyclesAndOneNonEssentialEdge() {
        let graph = Graph(values: [1, 2, 3, 4, 5, 6, 7],
                          edges: [(1, 2), (2, 3), (3, 1), (3, 4), (4, 5), (5, 6), (6, 4), (6, 7), (3, 7)])
        
        XCTAssertEqual(graph.findNonEssentialEdges(), [.init(3, 7)])
    }
}
