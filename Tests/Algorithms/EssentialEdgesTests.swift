@testable import SwiftNodes
import XCTest

class EssentialEdgesTests: XCTestCase {
    
    func testEmptyGraph() {
        XCTAssert(TestGraph().findEssentialEdges().isEmpty)
    }
    
    func testGraphWithoutEdges() {
        let graph = TestGraph(values: [1, 2, 3])
        
        XCTAssert(graph.findEssentialEdges().isEmpty)
    }
    
    func testGraphWithoutTransitiveEdges() {
        let graph = TestGraph(values: [1, 2, 3],
                              edges: [(1, 2), (2, 3)])
        
        XCTAssertEqual(graph.findEssentialEdges(),
                       [.init(1, 2), .init(2, 3)])
    }
    
    func testGraphWithOneTransitiveEdge() {
        let graph = TestGraph(values: [1, 2, 3],
                              edges: [(1, 2), (2, 3), (1, 3)])
        
        XCTAssertEqual(graph.findEssentialEdges(),
                       [.init(1, 2), .init(2, 3)])
    }
    
    func testAcyclicGraphWithManyTransitiveEdges() {
        var graph = TestGraph()
        
        let numberOfNodes = 10
        
        for j in 0 ..< numberOfNodes
        {
            graph.insert(j)
            
            for i in 0 ..< j
            {
                graph.insertEdge(from: i, to: j)
            }
        }
        
        // sanity check
        let expectedNumberOfEdges = ((numberOfNodes * numberOfNodes) - numberOfNodes) / 2
        XCTAssertEqual(graph.edges.count, expectedNumberOfEdges)
        
        // only edges between neighbouring numbers are essential (0 -> 1 -> 2 ...)
        
        var expectedEssentialEdges = Set<TestGraph.Edge.ID>()
        
        for i in 1 ..< numberOfNodes
        {
            expectedEssentialEdges.insert(.init(i - 1, i))
        }
        
        XCTAssertEqual(graph.findEssentialEdges(), expectedEssentialEdges)
    }
    
    func testGraphWithTwoCyclesAndOnlyEssentialEdges() {
        let graph = TestGraph(values: [1, 2, 3, 4, 5, 6],
                              edges: [(1, 2), (2, 3), (3, 1), (3, 4), (4, 5), (5, 6), (6, 4)])
        
        XCTAssertEqual(graph.findEssentialEdges(), Set(graph.edgeIDs))
    }
    
    func testGraphWithTwoCyclesAndOneNonEssentialEdge() {
        let graph = TestGraph(values: [1, 2, 3, 4, 5, 6, 7],
                              edges: [(1, 2), (2, 3), (3, 1), (3, 4), (4, 5), (5, 6), (6, 4), (6, 7), (3, 7)])
        
        let allEdgesExceptNonEssentialOne = Set(graph.edgeIDs).subtracting([.init(3, 7)])
        
        XCTAssertEqual(graph.findEssentialEdges(), allEdgesExceptNonEssentialOne)
    }
}
