@testable import SwiftNodes
import XCTest

class EssentialEdgesTests: XCTestCase {
    
    func testEmptyGraph() {
        XCTAssert(Graph<Int, Int>().findEssentialEdges().isEmpty)
    }
    
    func testGraphWithoutEdges() {
        let graph = Graph(values: [1, 2, 3])
        
        XCTAssert(graph.findEssentialEdges().isEmpty)
    }
    
    func testGraphWithoutTransitiveEdges() {
        let graph = Graph(values: [1, 2, 3],
                          edges: [(1, 2), (2, 3)])
        
        XCTAssertEqual(graph.findEssentialEdges(),
                       [.init(1, 2), .init(2, 3)])
    }
    
    func testGraphWithOneTransitiveEdge() {
        let graph = Graph(values: [1, 2, 3],
                          edges: [(1, 2), (2, 3), (1, 3)])
        
        XCTAssertEqual(graph.findEssentialEdges(),
                       [.init(1, 2), .init(2, 3)])
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
        
        var expectedEssentialEdges = Set<GraphEdge<Int>.ID>()
        
        for i in 1 ..< numberOfNodes
        {
            expectedEssentialEdges.insert(.init(i - 1, i))
        }
        
        XCTAssertEqual(graph.findEssentialEdges(), expectedEssentialEdges)
    }
    
    func testGraphWithTwoCyclesAndOnlyEssentialEdges() {
        let graph = Graph(values: [1, 2, 3, 4, 5, 6],
                          edges: [(1, 2), (2, 3), (3, 1), (3, 4), (4, 5), (5, 6), (6, 4)])
        
        XCTAssertEqual(graph.findEssentialEdges(), Set(graph.edgeIDs))
    }
    
    func testGraphWithTwoCyclesAndOneNonEssentialEdge() {
        let graph = Graph(values: [1, 2, 3, 4, 5, 6, 7],
                          edges: [(1, 2), (2, 3), (3, 1), (3, 4), (4, 5), (5, 6), (6, 4), (6, 7), (3, 7)])
        
        let allEdgesExceptNonEssentialOne = Set(graph.edgeIDs).subtracting([.init(3, 7)])
        
        XCTAssertEqual(graph.findEssentialEdges(), allEdgesExceptNonEssentialOne)
    }
}
