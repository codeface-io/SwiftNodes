@testable import SwiftNodes
import XCTest

class MEGTests: XCTestCase {
    
    func testEmptyGraph() {
        XCTAssertEqual(TestGraph().filteredTransitiveReduction(), TestGraph())
    }
    
    func testGraphWithoutEdges() {
        let graph = TestGraph(values: [1, 2, 3])
        
        XCTAssertEqual(graph.filteredTransitiveReduction(), graph)
    }
    
    func testGraphWithoutTransitiveEdges() {
        let graph = TestGraph(values: [1, 2, 3],
                              edges: [(1, 2), (2, 3)])
        
        XCTAssertEqual(graph.filteredTransitiveReduction(), graph)
    }
    
    func testGraphWithOneTransitiveEdge() {
        let graph = TestGraph(values: [1, 2, 3],
                              edges: [(1, 2), (2, 3), (1, 3)])
        
        let expectedMEG = TestGraph(values: [1, 2, 3],
                                    edges: [(1, 2), (2, 3)])
        
        XCTAssertEqual(graph.filteredTransitiveReduction(), expectedMEG)
    }
    
    func testGraphWithTwoComponentsEachWithOneTransitiveEdge() {
        let graph = TestGraph(values: [1, 2, 3, 4, 5, 6],
                              edges: [(1, 2), (2, 3), (1, 3), (4, 5), (5, 6), (4, 6)])
        
        let expectedMEG = TestGraph(values: [1, 2, 3, 4, 5, 6],
                                    edges: [(1, 2), (2, 3), (4, 5), (5, 6)])
        
        XCTAssertEqual(graph.filteredTransitiveReduction(), expectedMEG)
    }
    
    func testGraphWithManyTransitiveEdges() {
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
        
        // only edges between neighbouring numbers should remain (0 -> 1 -> 2 ...)
        
        var expectedMEG = TestGraph()
        
        for i in 0 ..< numberOfNodes
        {
            expectedMEG.insert(i)
            
            if i > 0
            {
                expectedMEG.insertEdge(from: i - 1, to: i)
            }
        }
        
        XCTAssertEqual(graph.filteredTransitiveReduction(), expectedMEG)
    }
}
