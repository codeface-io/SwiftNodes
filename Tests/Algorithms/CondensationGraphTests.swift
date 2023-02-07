@testable import SwiftNodes
import XCTest

class CondensationGraphTests: XCTestCase {
    
    func testGraphWithoutEdges() {
        let graph = TestGraph(values: [1, 2, 3])
        
        let condensationGraph = graph.makeCondensationGraph()
        
        let expectedCondensationGraph = TestGraph.CondensationGraph(
            values: [
                .init(nodeIDs: [1]),
                .init(nodeIDs: [2]),
                .init(nodeIDs: [3])
            ]
        )
        
        XCTAssertEqual(condensationGraph, expectedCondensationGraph)
    }
    
    func testGraphWithoutCycles() {
        let graph = TestGraph(values: [1, 2, 3, 4],
                              edges: [(1, 2), (2, 3), (3, 4), (1, 3), (2, 4)])
        
        let condensationGraph = graph.makeCondensationGraph()
        
        let expectedEdges: [(Set<Int>, Set<Int>)] =
        [
            ([1], [2]), ([2], [3]), ([3], [4]), ([1], [3]), ([2], [4])
        ]
        
        let expectedCondensationGraph = TestGraph.CondensationGraph(
            values: [
                .init(nodeIDs: [1]),
                .init(nodeIDs: [2]),
                .init(nodeIDs: [3]),
                .init(nodeIDs: [4])
            ],
            edges: expectedEdges
        )
        
        XCTAssertEqual(condensationGraph, expectedCondensationGraph)
    }
    
    func testGraphMadeOfOneCycle() {
        let graph = TestGraph(values: [1, 2, 3, 4],
                              edges: [(1, 2), (2, 3), (3, 4), (4, 1)])
        
        let condensationGraph = graph.makeCondensationGraph()
        
        let expectedCondensationGraph = TestGraph.CondensationGraph(
            values: [.init(nodeIDs: [1, 2, 3, 4])]
        )
        
        XCTAssertEqual(condensationGraph, expectedCondensationGraph)
    }
    
    func testGraphContainingOneCycle() {
        let graph = TestGraph(values: [1, 2, 3, 4],
                              edges: [(1, 2), (2, 3), (3, 1), (3, 4)])
        
        let condensationGraph = graph.makeCondensationGraph()
        
        let expectedEdges: [(Set<Int>, Set<Int>)] = [([1, 2, 3], [4])]
        
        let expectedCondensationGraph = TestGraph.CondensationGraph(
            values: [.init(nodeIDs: [1, 2, 3]), .init(nodeIDs: [4])],
            edges: expectedEdges
        )
        
        XCTAssertEqual(condensationGraph, expectedCondensationGraph)
    }
    
    func testGraphContainingTwoCycles() {
        let graph = TestGraph(values: [1, 2, 3, 4, 5, 6],
                              edges: [(1, 2), (2, 3), (3, 1), (3, 4), (4, 5), (5, 6), (6, 4)])
        
        let condensationGraph = graph.makeCondensationGraph()
        
        let expectedEdges: [(Set<Int>, Set<Int>)] = [([1, 2, 3], [4, 5, 6])]
        
        let expectedCondensationGraph = TestGraph.CondensationGraph(
            values: [.init(nodeIDs: [1, 2, 3]), .init(nodeIDs: [4, 5, 6])],
            edges: expectedEdges
        )
        
        XCTAssertEqual(condensationGraph, expectedCondensationGraph)
    }
    
    func testGraphContainingTwoComponents() {
        let graph = TestGraph(values: [1, 2, 3, 4, 5, 6],
                              edges: [(1, 2), (2, 3), (1, 3), (4, 5), (5, 6), (6, 4)])
        
        let condensationGraph = graph.makeCondensationGraph()
        
        let expectedEdges: [(Set<Int>, Set<Int>)] = [([1], [2]), ([2], [3]), ([1], [3])]
        
        let expectedCondensationGraph = TestGraph.CondensationGraph(
            values: [
                .init(nodeIDs: [1]),
                .init(nodeIDs: [2]),
                .init(nodeIDs: [3]),
                .init(nodeIDs: [4, 5, 6])
            ],
            edges: expectedEdges
        )
        
        XCTAssertEqual(condensationGraph, expectedCondensationGraph)
    }
}
