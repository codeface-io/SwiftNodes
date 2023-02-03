@testable import SwiftNodes
import XCTest

class MEGTests: XCTestCase {
    
    func testEmptyGraph() {
        XCTAssertEqual(Graph<Int, Int>().makeMinimumEquivalentGraph(), Graph<Int, Int>())
    }
    
    func testGraphWithoutEdges() {
        let graph = Graph(values: [1, 2, 3])
        
        XCTAssertEqual(graph.makeMinimumEquivalentGraph(), graph)
    }
    
    func testGraphWithoutTransitiveEdges() {
        let graph = Graph(values: [1, 2, 3],
                          edges: [(1, 2), (2, 3)])
        
        XCTAssertEqual(graph.makeMinimumEquivalentGraph(), graph)
    }
    
    func testGraphWithOneTransitiveEdge() {
        let graph = Graph(values: [1, 2, 3],
                          edges: [(1, 2), (2, 3), (1, 3)])
        
        let expectedMEG = Graph(values: [1, 2, 3],
                                edges: [(1, 2), (2, 3)])
        
        XCTAssertEqual(graph.makeMinimumEquivalentGraph(), expectedMEG)
    }
    
    func testGraphWithManyTransitiveEdges() {
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
        
        // only edges between neighbouring numbers should remain (0 -> 1 -> 2 ...)
        
        var expectedMEG = Graph<Int, Int>()
        
        for i in 0 ..< numberOfNodes
        {
            expectedMEG.insert(i)
            
            if i > 0
            {
                expectedMEG.addEdge(from: i - 1, to: i)
            }
        }
        
        XCTAssertEqual(graph.makeMinimumEquivalentGraph(), expectedMEG)
    }
}
